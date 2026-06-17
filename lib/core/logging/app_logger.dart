import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

export 'package:talker_flutter/talker_flutter.dart' show Talker;

/// App-wide logging via Talker. One global instance ([AppLogger.talker]),
/// mirroring the `GameBalance.I` singleton style.
///
/// The engine is **debug-only**: `enabled = kDebugMode`, so in release every
/// `info/warning/error/handle` call is a no-op and nothing is retained — no
/// overhead, no scattered guards needed at call sites. The in-app log viewer
/// (`TalkerScreen`) and the Bloc/Dio integrations are likewise only wired up
/// behind `kDebugMode`.
///
/// Convention: prefix messages with a short area tag, e.g.
/// `AppLogger.talker.info('[sync] batch sent (3)')`,
/// `AppLogger.talker.handle(e, st, '[run] recordCompletedRun failed')`.
abstract final class AppLogger {
  static final Talker talker = Talker(
    settings: TalkerSettings(
      enabled: kDebugMode,
      useConsoleLogs: kDebugMode,
    ),
  );
}
