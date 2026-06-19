import 'dart:convert';
import 'dart:typed_data';

import 'package:deadbounce_flutter_app/core/network/api_client.dart';
import 'package:deadbounce_flutter_app/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [TokenStorage] — overrides every method so the secure-storage
/// platform channel is never touched in a unit test.
class _MemTokenStorage extends TokenStorage {
  _MemTokenStorage(this.token);
  String? token;
  @override
  Future<String?> readAccessToken() async => token;
  @override
  Future<void> saveAccessToken(String value) async => token = value;
  @override
  Future<void> clear() async => token = null;
}

/// A scripted Dio adapter: replies based on the request's bearer token, so we
/// can model "old token → 401, new token → 200" deterministically.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._reply);
  final ResponseBody Function(RequestOptions options) _reply;
  final List<RequestOptions> seen = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    return _reply(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body, int status) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

String? _bearer(RequestOptions o) => o.headers['Authorization'] as String?;

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'API_BASE_URL_DEV=http://localhost');
  });

  ApiClient build(_MemTokenStorage store, _ScriptedAdapter adapter) {
    final dio = Dio()..httpClientAdapter = adapter;
    return ApiClient(store, dio: dio);
  }

  test('a 401 triggers one silent refresh and replays with the new token',
      () async {
    final store = _MemTokenStorage('old');
    final adapter = _ScriptedAdapter((o) => _bearer(o) == 'Bearer new'
        ? _json({'ok': true}, 200)
        : _json({'error': 'unauthorized'}, 401));
    var refreshes = 0;
    final client = build(store, adapter)
      ..attachSessionRefresher(() async {
        refreshes++;
        store.token = 'new';
        return true;
      });

    final data = await client.get('/auth/me');

    expect(data['ok'], isTrue);
    expect(refreshes, 1);
    expect(adapter.seen.length, 2, reason: 'original + one replay');
    expect(_bearer(adapter.seen.last), 'Bearer new');
  });

  test('never tries to refresh the /auth/firebase exchange itself', () async {
    final store = _MemTokenStorage('old');
    final adapter =
        _ScriptedAdapter((o) => _json({'error': 'unauthorized'}, 401));
    var refreshes = 0;
    final client = build(store, adapter)
      ..attachSessionRefresher(() async {
        refreshes++;
        return true;
      });

    await expectLater(
      client.post('/auth/firebase', body: {'firebase_token': 'x'}),
      throwsA(isA<ApiException>().having((e) => e.isUnauthorized, '401', true)),
    );
    expect(refreshes, 0);
    expect(adapter.seen.length, 1, reason: 'no replay on the refresh endpoint');
  });

  test('gives up without looping when the refresh fails', () async {
    final store = _MemTokenStorage('old');
    final adapter =
        _ScriptedAdapter((o) => _json({'error': 'unauthorized'}, 401));
    var refreshes = 0;
    final client = build(store, adapter)
      ..attachSessionRefresher(() async {
        refreshes++;
        return false; // can't refresh (e.g. offline)
      });

    await expectLater(
      client.get('/auth/me'),
      throwsA(isA<ApiException>().having((e) => e.isUnauthorized, '401', true)),
    );
    expect(refreshes, 1, reason: 'attempted once, then surfaced the 401');
    expect(adapter.seen.length, 1, reason: 'no replay when refresh fails');
  });

  test('concurrent 401s share a single refresh (single-flight)', () async {
    final store = _MemTokenStorage('old');
    final adapter = _ScriptedAdapter((o) => _bearer(o) == 'Bearer new'
        ? _json({'ok': true}, 200)
        : _json({'error': 'unauthorized'}, 401));
    var refreshes = 0;
    final client = build(store, adapter)
      ..attachSessionRefresher(() async {
        refreshes++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        store.token = 'new';
        return true;
      });

    final results =
        await Future.wait([client.get('/auth/me'), client.get('/auth/me')]);

    expect(results.every((r) => r['ok'] == true), isTrue);
    expect(refreshes, 1, reason: 'both 401s coalesced into one refresh');
  });
}
