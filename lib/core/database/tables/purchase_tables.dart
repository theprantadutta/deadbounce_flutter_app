import 'package:drift/drift.dart';

/// A capability the player owns, as the SERVER last reported it.
///
/// Unlike almost everything else in this database, the client is **not**
/// authoritative here — this is a read-through cache of
/// `GET /purchases/entitlements` (and of the snapshot on a fresh install),
/// kept locally so the ad gate and the store still answer correctly offline.
/// Nothing in the app ever writes a row here that the server didn't send.
@DataClassName('EntitlementRow')
class Entitlements extends Table {
  /// Catalog capability key, e.g. `no_ads`. Not the Play SKU — several SKUs
  /// can grant the same capability.
  TextColumn get entitlementKey => text()();

  /// The SKU that granted it (support/debugging only).
  TextColumn get productId => text()();

  IntColumn get grantedAt => integer()();

  /// Null for permanent entitlements; set for subscriptions.
  IntColumn get expiresAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {entitlementKey};
}

/// Purchase tokens this device has already redeemed and mirrored locally.
///
/// Exists for exactly one reason: **credit the local coin ledger once, and
/// only once.** The server is idempotent by purchase token, so re-verifying is
/// harmless there — but the client also writes a local ledger entry for
/// instant offline display, and without this table a retried verify (dropped
/// response, app killed mid-flow, restore-purchases replay) would credit the
/// player's visible balance again and drift it away from the server's.
@DataClassName('ProcessedPurchaseRow')
class ProcessedPurchases extends Table {
  /// Google Play's purchase token — globally unique per purchase, forever.
  TextColumn get purchaseToken => text()();

  TextColumn get productId => text()();

  /// Coins the SERVER said this purchase was worth. Never client-computed.
  IntColumn get coinsGranted => integer().withDefault(const Constant(0))();

  IntColumn get processedAt => integer()();

  @override
  Set<Column> get primaryKey => {purchaseToken};
}
