import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/features/game/presentation/trickshot/trickshot_progress_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TrickShotProgressRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TrickShotProgressRepository(db);
  });
  tearDown(() => db.close());

  Future<Map<String, TrickShotProgress>> read() => repo.watchProgress().first;

  test('recordClear marks cleared and stores best shots', () async {
    await repo.recordClear('ts_01', 5);
    final p = (await read())['ts_01']!;
    expect(p.cleared, isTrue);
    expect(p.bestShots, 5);
  });

  test('recordClear keeps the FEWEST shots across attempts', () async {
    await repo.recordClear('ts_01', 5);
    await repo.recordClear('ts_01', 8); // worse — ignored
    expect((await read())['ts_01']!.bestShots, 5);
    await repo.recordClear('ts_01', 3); // better — kept
    expect((await read())['ts_01']!.bestShots, 3);
  });

  test('levels are independent; uncleared levels are absent', () async {
    await repo.recordClear('ts_02', 4);
    final p = await read();
    expect(p['ts_02']!.cleared, isTrue);
    expect(p.containsKey('ts_01'), isFalse);
  });
}
