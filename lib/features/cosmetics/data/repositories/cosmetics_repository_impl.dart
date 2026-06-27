import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/sync/sync_event.dart';
import '../../../../core/sync/sync_outbox_writer.dart';
import '../../../economy/domain/entities/coin_transaction.dart';
import '../../domain/cosmetic_catalog.dart';
import '../../domain/cosmetic_loadout.dart';
import '../../domain/repositories/cosmetics_repository.dart';

class CosmeticsRepositoryImpl implements CosmeticsRepository {
  CosmeticsRepositoryImpl({
    required this._db,
    required this._outboxWriter,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncOutboxWriter _outboxWriter;
  final Uuid _uuid;

  @override
  Stream<Set<String>> watchOwned() =>
      _db.cosmeticsDao.watchOwned().map((rows) {
        final owned = rows.map((r) => r.cosmeticId).toSet();
        for (final c in CosmeticCatalog.all) {
          if (c.isFree) owned.add(c.id); // free stock looks are always owned
        }
        return owned;
      });

  @override
  Stream<Map<CosmeticSlot, String>> watchEquipped() =>
      _db.cosmeticsDao.watchEquipped().map((rows) {
        final map = <CosmeticSlot, String>{};
        for (final r in rows) {
          final slot = _slotByName(r.slot);
          if (slot != null) map[slot] = r.cosmeticId;
        }
        return map;
      });

  @override
  Future<CosmeticLoadout> loadout() async {
    final rows = await _db.cosmeticsDao.getEquipped();
    final map = <CosmeticSlot, String>{};
    for (final r in rows) {
      final slot = _slotByName(r.slot);
      if (slot != null) map[slot] = r.cosmeticId;
    }
    return CosmeticLoadout.fromEquipped(map);
  }

  @override
  Future<void> purchase(Cosmetic cosmetic) async {
    if (cosmetic.isFree) return; // nothing to buy
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _db.transaction(() async {
      if (await _db.cosmeticsDao.isOwned(cosmetic.id)) {
        throw const CosmeticPurchaseException('You already own that.');
      }
      final balance = await _db.coinLedgerDao.getBalance();
      if (balance < cosmetic.cost) {
        throw const CosmeticPurchaseException('Not enough coins, partner.');
      }

      final txnId = _uuid.v4();
      await _db.coinLedgerDao.insertTransaction(CoinLedgerRow(
        id: txnId,
        amount: -cosmetic.cost,
        reason: CoinReason.shopPurchase.name,
        runId: null,
        createdAt: nowMs,
      ));
      await _outboxWriter.enqueue(
        SyncEntityType.coinTxn,
        {
          'txn_id': txnId,
          'amount': -cosmetic.cost,
          'reason': CoinReason.shopPurchase.name,
          'run_id': null,
          'created_at': DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true)
              .toIso8601String(),
        },
        eventId: txnId,
      );
      await _db.cosmeticsDao.addOwned(cosmetic.id, nowMs);
      await _enqueueState(nowMs);
    });

    AppLogger.talker.info('[cosmetics] purchased ${cosmetic.id}');
  }

  @override
  Future<void> equip(Cosmetic cosmetic) async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _db.transaction(() async {
      if (!cosmetic.isFree && !await _db.cosmeticsDao.isOwned(cosmetic.id)) {
        throw const CosmeticPurchaseException("You don't own that yet.");
      }
      await _db.cosmeticsDao.setEquipped(cosmetic.slot.name, cosmetic.id, nowMs);
      await _enqueueState(nowMs);
    });
    AppLogger.talker.info('[cosmetics] equipped ${cosmetic.id}');
  }

  /// Enqueues the full owned+equipped aggregate (last-writer-wins server-side).
  Future<void> _enqueueState(int nowMs) async {
    final ownedRows = await _db.cosmeticsDao.getOwned();
    final equippedRows = await _db.cosmeticsDao.getEquipped();
    await _outboxWriter.enqueue(
      SyncEntityType.cosmeticState,
      {
        'owned': ownedRows.map((r) => r.cosmeticId).toList(),
        // Emit snake_case slot keys (wireName) so ingest matches the casing the
        // backend stores and returns in the snapshot. Falls back to the raw
        // stored name if the slot is somehow unrecognized.
        'equipped': {
          for (final r in equippedRows)
            (_slotByName(r.slot)?.wireName ?? r.slot): r.cosmeticId,
        },
        'updated_at': nowMs,
      },
      eventId: _uuid.v4(),
    );
  }

  CosmeticSlot? _slotByName(String name) {
    for (final s in CosmeticSlot.values) {
      if (s.name == name) return s;
    }
    return null;
  }
}
