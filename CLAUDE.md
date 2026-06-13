# Deadbounce — Flutter App (living source of truth)

A one-thumb, portrait, wave-based neon arena shooter. **The hook: your bullets
do ZERO damage on a direct hit. They only become lethal after ricocheting off
walls — each bounce adds +1 damage and +12% speed.** Neo-western neon: near-black
ink base, amber primary, electric-blue accent.

This file is the living summary for future sessions. Keep it updated as decisions
change. The backend lives in the sibling repo `deadbounce-dotnet-api` (its own
CLAUDE.md / SETUP.md).

---

## Core mechanic & rules

- **Aim**: drag anywhere (relative slingshot from the drag origin, so the thumb
  never covers the arena). A predicted ricochet line renders in real time and is
  guaranteed to match the bullet (same solver). Drag length sets launch power.
- **Fire**: release past the 24px deadzone. A tap (or sub-deadzone release)
  **dashes** the player to the nearest of 3 bottom-third anchors — movement is
  not the skill, aiming is. (Decision: 3-anchor tap-dash, not fixed position.)
- **Damage**: `bounces == 0 → 0 damage` (passes through enemies — enables
  skill shots lining enemies up behind walls). After N bounces: `N × damagePerBounce`.
- **Bullets persist after kills** (chains are the point) until they expire
  (8 bounces or 4s).
- **Turret-dampened walls**: while a Turret holds a wall section it reflects with
  0.55 restitution and **grants no bounce** — kill the turret to make it lethal again.
- Clear a wave → pick 1 of 3 rarity-weighted upgrade cards → next wave is harder.
  3 hearts; enemy contact costs a heart + i-frames; 0 hearts ends the run.

## Enemy roster (`features/game/presentation/game/components/enemies/`)

| Enemy | HP | Behavior |
|---|---|---|
| Drifter | 1 | Slow seek + lateral wobble. Splitter children are the `small` variant. |
| Charger | 2 | roam → telegraph (0.5s, dash vector locks here = dodge window) → raycast-clamped dash → recover |
| Splitter | 2 | Drifts; on death spawns 2 small Drifters via the SpawnDirector |
| Turret | 4 | Claims a wall slot, dampens it, fires interceptable projectiles. Bulletproof release on remove. |
| Warden (every 5th wave) | 3 phases × 14hp | Shield blocks <3-bounce bullets (CLANG reflect); phase break = hit-stop + shake + shield-down window |

Waves 1–15 are authored (`engine/waves/wave_table.dart`); past 15 `wave_scaling.dart`
composes endless waves (count +0.8/wave, hp +8%/wave, capped speed), Warden every 5th.

## Upgrades — composable modifier pipeline (`engine/upgrades/`)

Pure stat folds (`transformPlayerStats`/`transformBulletStats`) + behavior hooks
(`onFire/onBounce/onBulletUpdate/onKill/onPlayerDamaged/onCoinEarned`) over a
fakeable `GameWorldOps`. **No if-else spaghetti** — bullet/player code dispatches
hooks at fixed points and never knows which upgrades exist. 12 cards: Split Shot,
Incendiary Trail, Rubber Walls, Longer Sight, Magnet Rounds, Ghost Round,
Quickdraw, Heart Container, Coin Magnet, Last Stand, Heavy Caliber, Echo Shot.
Rarity weights common 100 / rare 40 / epic 12.

> **Accepted divergence**: Magnet Rounds curves bullets after bounce 2; the aim
> preview stays geometric (homing is a forgiveness mechanic, not an aiming one).

## Tuning

All constants live in `engine/tuning.dart` (one file). Current values are starting
points — tune by feel there. Highlights: bullet base/max speed 420/780, +12%/bounce,
8 max bounces / 4s lifetime; player 3 hearts, 0.55s fire cooldown, 2 preview bounces;
hit-stop 45/60ms; particle budget 600.

## Economy & meta

- **Coins are a ledger, never a mutated int.** Every change is a `coin_ledger`
  transaction (reason enum) in Drift; the cached `coin_balance` row is updated in
  the same transaction. Run earnings are one txn at run end (not per pickup).
- **Daily login streak**: keyed on the **device-local calendar date**. The absolute
  streak is derived by walking the trailing run of consecutive claim dates (correct
  across week/month boundaries). 7-day escalating reward calendar (`login_rewards.dart`),
  wraps while preserving the absolute count. Rule, verbatim: *a "day" is the device's
  local calendar date at claim time; the streak continues iff the last claim was the
  local day before today, else resets to 1; the server dedupes by date string and
  only ever advances.*
- **Daily challenges**: a run-shaping `ChallengeConfig` derived from the UTC-date
  seed (`engine/challenge/`), identical worldwide and offline — forced enemy type,
  +wall damage, heart cap, score multiplier, or random-dealt upgrades. Scores submit
  to a separate daily-challenge board.
- **Achievements** (24, `features/achievements/domain/achievement_catalog.dart`):
  in-app definitions; ids + coin rewards mirror the backend's validation catalog
  exactly. Evaluated locally after each run against lifetime stats. **Unlock and
  claim are separate** — claiming grants the coin reward (ledger) and emits the one
  `achievementUnlock` sync event.
- **Leaderboards**: cache-first (Drift) with last-synced + pinned player rank;
  refreshed from the server. Daily/Weekly/All-time/Daily-Challenge tabs.

## Offline-first architecture (the spine)

**Drift (SQLite) is the client source of truth. Every write hits Drift first,
synchronously with the UI; the backend is updated asynchronously via the outbox.
The game is 100% playable offline after first sign-in.**

- **One database file per account** (`deadbounce_<firebaseUid>.sqlite`). Firebase
  keeps the UID through guest→linked, so local data survives linking for free, and
  accounts never mix on a shared device.
- **Outbox** (`core/sync/`): every syncable mutation is written to `sync_outbox` in
  the **same Drift transaction** as its domain write. `SyncWorker` drains single-flight
  in `createdAt` order, batching ≤50 into one `POST /api/sync/batch`. Per-item results:
  applied/duplicate→done, rejected→failed (permanent), transport error→pending with
  full-jitter backoff (5s·2^n capped 10min, 8 attempts). `inFlight`→`pending` recovery
  on start (server dedupes by event id). Triggers: foreground, connectivity regained,
  2.5-min timer, manual.
- **One-time restore**: on sign-in, if `initialSyncCompleted` is false →
  `GET /api/sync/snapshot` once, hydrate in one transaction (seeds the wallet with a
  single `snapshotRestore` ledger entry), set the flag, never pull again.
- **Conflict policy**: the client is authoritative for its own gameplay data (server
  applies events); the server is authoritative for leaderboards and validated
  aggregates. Multi-device divergence (e.g. local streak) is accepted by design.

## Project structure

```
lib/
  core/        config (.env via flutter_dotenv), network (Dio ApiClient),
               storage (secure token), database (Drift: tables/, daos/),
               sync/ (outbox writer, worker, triggers, snapshot restorer),
               di/ (SessionDependencies — per-account graph), router/, theme/,
               util/ (CalendarDay), widgets/ (design system + shared UI)
  features/<f>/  domain (entities/repositories/usecases) → data (datasources/
               models/repositoryimpl) → presentation (cubits/pages)
               f ∈ auth, game, runs, economy, streak, challenges, achievements,
                   leaderboards, profile, settings, home, splash
```

`app.dart` is the composition root: app-wide graph (auth, ApiClient) built once;
`SessionDependencies` (per-account DB + sync engine + game-data repositories) built
by `_SessionScope` when auth lands on a uid, torn down on sign-out. Read it in
post-auth screens via `context.sessionDependencies`.

## Key decisions

- 3-anchor tap-dash movement (documented above).
- Achievement & challenge definitions ship in-app; only results/unlocks sync.
- One Drift file per account; period-keyed leaderboards on the backend.
- Generated `*.g.dart` (Drift) is committed (no CI codegen step; `flutter analyze`
  is the gate).
- `kotlin.incremental=false` in `android/gradle.properties` — the incremental cache
  corrupts on this drive. Don't remove it.
- Config in `.env` (loaded by flutter_dotenv); dev/prod API URL by `kDebugMode`.

## Run & test

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after Drift schema changes
flutter analyze        # must be clean — the commit gate
flutter test           # pure-logic + Drift in-memory tests
flutter run            # debug → API_BASE_URL_DEV; release → API_BASE_URL_PROD
```

Tests cover the load-bearing logic: ricochet reflection + anti-tunneling,
trajectory↔bullet parity (all arenas), damage/score scaling, upgrade pipeline
composition, wave scaling, RNG/daily-seed determinism (golden), outbox
batching/idempotency + atomicity, ledger balance, streak rollover, challenge-seed
determinism, achievement evaluate/claim.

## Intentionally stubbed / next phase

- **Sound**: `SoundManager` is a silent no-op behind an abstract class — see
  `SFX_WISHLIST.md` for the asset list to drop in (one file per `Sfx` enum value).
- **Account linking** (guest→Google): the architecture supports it (per-account
  file survives, `accountLinked` event exists), but the Profile CTA currently shows
  "coming soon". Real `linkWithCredential` is the next step.
- **Apple Sign-In**: button placeholder (Phase 1).
- Final art (the logo is a styled Material icon), shop/monetization (the ledger
  prepares for it), PvP.
