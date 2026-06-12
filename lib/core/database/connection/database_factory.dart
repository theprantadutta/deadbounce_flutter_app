import 'package:drift_flutter/drift_flutter.dart';

import '../app_database.dart';

/// Opens the Drift database for one account. The file name embeds the
/// Firebase UID, so:
/// - guest → linked account keeps the SAME file (Firebase preserves the
///   UID through linkWithCredential), local data survives linking;
/// - signing into a different account opens a different file — data never
///   mixes between accounts on a shared device.
AppDatabase openAccountDatabase(String firebaseUid) {
  return AppDatabase(
    driftDatabase(name: 'deadbounce_$firebaseUid'),
  );
}
