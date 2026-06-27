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
- **Run-end flow**: `endRun()` freezes the kill (hit-stop + shake), then the cubit
  emits a transient **`SessionRunEnding`** "death beat" (`RunEndingOverlay`) — a
  ~1.4s pause naming what felled you (the fatal enemy via `causeOfDeath` on the
  run snapshot) and the wave, tap-to-skip — and records the run + evaluates
  achievements in parallel, before emitting `SessionRunOver` (the results screen).

## Enemy roster (`features/game/presentation/game/components/enemies/`)

| Enemy | HP | Behavior |
|---|---|---|
| Drifter | 1 | Slow seek + lateral wobble. Splitter children are the `small` variant. |
| Charger | 2 | roam → telegraph (0.7s, dash vector locks here = dodge window) → raycast-clamped dash → recover |
| Splitter | 2 | Drifts; on death spawns 2 small Drifters via the SpawnDirector |
| Turret | 4 | Claims a wall slot, dampens it, fires interceptable projectiles. Bulletproof release on remove. |
| Warden (first at wave 10, then every 5th) | 3 phases × 14hp | Shield blocks <3-bounce bullets (CLANG reflect); phase break = hit-stop + shake + shield-down window |
| Powderkeg (intro w7) | 2 | Slow seeker; on death drops a telegraphed `ShockwaveComponent` that detonates after a fuse, hazard-damaging the player in a zone (`player.takeHazardDamage`). Spatial play — punishes camping kills; never buffs bullets. |
| Sawbones (intro w11) | 3 | Mender: every `healInterval` heals living non-Sawbones enemies in `healRadius` via `EnemyComponent.receiveHeal`. Priority target. |
| Ironhide (intro w9) | 6 | Directional armor: a frontal shield arc faces the player and CLANGs off shots (reuses the Warden reflect). Crack it from the side/back via bounces. |
| Mirror (intro w13) | 2 | Carries a **one-sided `WallSegment`** (`isMirror`) added to `game.segments`, so the shared solver + aim preview reflect it truthfully (front = real bounce, a free-bounce tool). Front always faces the player; killable only from the back face (`canBeDamagedBy` gates on `velocity·normal > 0`). Removed from `segments` on death. ArenaComponent skips drawing `isMirror` segments. |

**Difficulty philosophy (do not undo): the first 3 waves must feel trivial** —
only slow Drifters with generous spacing — then difficulty stays near-flat early
and accelerates later. Enemy introductions: Drifter w1, Charger w4 (long, obvious
telegraph), Splitter w6, Powderkeg w7, Turret w8, Ironhide w9, **first Warden w10**
(kept late so the early game is kind; every 5th thereafter — 15, 20, …), Sawbones
w11, Mirror w13. Waves 1–15 are authored
(`engine/waves/wave_table.dart`); past 15 `wave_scaling.dart` composes endless
waves where hp/speed grow as `growth × past^exponent` (shallow-then-steep, the
exponent tunable). The on-ramp parameters (`firstWardenWave`, curve exponents,
Charger telegraph, post-hit i-frames) live in `GameBalance` and are panel-tunable.

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

## Tuning — `GameBalance` is the balance source of truth

Every tunable gameplay number lives in **`lib/core/config/game_balance.dart`** as a
**mutable singleton** (`GameBalance.I`). Game systems read `GameBalance.I.<section>.<x>`
live (no const-folding), so values can change at runtime and be felt on the next
read (next shot / wave / event). It is pure Dart (no Flutter import) so the engine
and tests stay testable. Sections: bullet, player, drifter, charger, splitter,
turret, warden, waves, juice, input, trajectory, economy, score — field
initializers ARE the shipped defaults; `resetToDefaults()` restores them.

Highlights (defaults): bullet base/max speed 420/780, +12%/bounce, 8 max bounces /
4s lifetime; player 3 hearts, 0.55s fire cooldown, 2 preview bounces; hit-stop
45/60ms; particle budget 600.

A flat `params` registry (each a `TuningParam` with get/set + min/max/step/scope)
is the single source driving the debug tuning panel, JSON persistence, reset, and
"copy config". Tests `resetToDefaults()` in `setUp` so a panel/test mutation can't
leak across cases (keeps daily-challenge wave goldens deterministic).

## Economy & meta

- **Coins are a ledger, never a mutated int.** Every change is a `coin_ledger`
  transaction (reason enum) in Drift; the cached `coin_balance` row is updated in
  the same transaction. Run earnings are one txn at run end (not per pickup).
- **Earn amounts flow from `GameBalance.I.economy`** (coins/kill, wave-clear bonus,
  chain bonus, drop chance/value) and the 7-day login table
  (`economy.loginRewardsByDay`) — all panel-tunable. Tuning only changes the
  *amounts* written to ledger txns; it never touches the ledger/transaction
  structure or sync. **Achievement & daily-challenge reward amounts are NOT in
  the live config** — they mirror the backend's validation catalog exactly and
  must not drift, so they stay in their catalogs.
- **Daily login streak**: keyed on the **device-local calendar date**. The absolute
  streak is derived by walking the trailing run of consecutive claim dates (correct
  across week/month boundaries). 7-day escalating reward calendar (amounts in
  `GameBalance.I.economy.loginRewardsByDay`, logic in `login_rewards.dart`),
  wraps while preserving the absolute count. Rule, verbatim: *a "day" is the device's
  local calendar date at claim time; the streak continues iff the last claim was the
  local day before today, else resets to 1; the server dedupes by date string and
  only ever advances.*
- **Daily challenges**: a run-shaping `ChallengeConfig` derived from the UTC-date
  seed (`engine/challenge/`; `dailySeed = fnv1a64("deadbounce-dc-yyyy-MM-dd")`),
  identical worldwide and **fully offline** (today's config + your best + attempt
  count are computed locally — no fetch to view or play) — forced enemy type,
  +wall damage, heart cap, score multiplier, or random-dealt upgrades. A run is
  recorded as a local `challenge_attempts` row and submits a `challengeResult`
  outbox event (carrying wave/duration/kills so the server **sanity-validates**
  the score like `scoreSubmit`, with 3× density headroom for the multiplier), which
  drives the **separate** daily-challenge board (`dc:yyyy-MM-dd`). Like tournaments,
  daily-challenge runs are seeded/constrained, so they **do NOT** emit `scoreSubmit`
  (no global-leaderboard pollution) and **do NOT** set lifetime personal-best stats
  (best_*), though activity counters (runs/kills/waves/play time) still count.
- **Tournaments** (`features/tournaments/`): the **backend generates** seeded,
  time-limited competitions in **daily/weekly/monthly** cadences (fees + reward pools
  scale by length); the client fetches them **cache-first** (`tournament_cache` Drift
  table + `TournamentDao`, mirrors the leaderboard cache). A server tournament's
  ruleset is JSON that `Tournament.toChallengeConfig()` maps onto the engine's
  `ChallengeConfig` + shared `seed`, so a tournament run **reuses the entire
  daily-challenge run path** (perks off for fairness). Flow: **join is online** (POST,
  pays a coin entry fee — `CoinReason.tournamentEntry`, synced as a `coinTxn` carrying
  `tournament_id`; the server flips the entry to paid) and caches the seed/config so
  you can **play offline** (best score counts; the run enqueues a `tournamentScore`
  outbox event and updates the local best — it does NOT emit the global `scoreSubmit`).
  When the window closes a Hangfire sweep ranks paid entries and assigns rank rewards;
  the client then **claims** the finalized reward — **offline-capable**: it credits the
  local ledger and enqueues a `CoinReason.tournamentReward` `coinTxn` carrying the
  `tournament_id`, and when that event eventually syncs the server **re-validates the
  amount against the finalized payout and enforces single-claim** before crediting. Run
  path: `GameSessionCubit.tournamentContext` → `Routes.tournamentRun`. **Offline:**
  list/board/result are cache-first with an offline banner, and **playing a joined
  tournament + claiming a reward both work offline**; only **join needs connectivity**
  (it pays the entry fee online). Join/claim UI flows are shared via
  `tournament_actions.dart`. (`TournamentRunContext`,
  `tournaments_screen`/`tournament_detail_screen`, `tournaments_feature_card` on home.)
- **The Gunsmith** (`features/meta/`): the coin SINK / permanent meta-progression.
  Spend coins on tiered perks that apply to **every normal run** (not daily
  challenges — those stay fair): Reinforced Heart, Iron Resolve, Quick Hands, Keen
  Eye, Lucky Strike, Second Wind. **Guardrail: perks never add flat bullet damage**
  (that would break "no damage till it bounces") — survivability/utility/economy only.
  Catalog in Dart (`meta_catalog.dart`); ownership LEVEL per perk in the
  `meta_upgrades` Drift table. Purchasing is offline-first (local ledger + level
  write), then both halves sync: the coin *spend* as a `shopPurchase` coinTxn and
  the owned-levels aggregate as a `metaState` event (last-writer-wins, restored
  from the snapshot on reinstall — mirrors cosmetics). The server validates the
  `metaState` aggregate against its perk catalog (`MetaPerkDefinitions`: unknown
  perks dropped, levels clamped to maxLevel). `RunModifiers.addPermanent` pre-loads the perk as a
  modifier (reusing existing card modifiers: heart_container/quickdraw/longer_sight/
  coin_magnet) without counting it as a wave pick; permanent stacks still respect each
  card's max-stacks cap. Applied in `game_session_cubit.startRun` via `MetaLoadout`.
- **The Outfitter** (`features/cosmetics/`): a second coin SINK, **visual-only**. Buy
  bullet trails / gunslinger skins / arena themes; spend goes through the coin ledger as
  `CoinReason.shopPurchase` (mirrors The Gunsmith). Owned + equipped state lives in two
  local Drift tables (`CosmeticOwned`/`CosmeticEquipped`, DB schema v4) and **syncs** as a
  `cosmeticState` aggregate event (owned ids + equipped-per-slot, last-writer-wins by
  `updated_at`; backend `CosmeticStateProcessor` + `PlayerCosmetic`; restored via
  `/sync/snapshot`) so paid items survive reinstall. Buying/equipping are offline-first
  (local Drift + outbox, no network). The wire uses snake_case slot keys
  (`CosmeticSlot.wireName`, e.g. `bullet_trail`) on both ingest and snapshot; the server
  validates the aggregate against its catalog (`CosmeticDefinitions`: unknown owned ids
  dropped, equipped kept only when the id belongs to that slot). Catalog in Dart
  (`cosmetic_catalog.dart`), free stock looks always owned. Applied at run start via an
  immutable `CosmeticLoadout` (sibling of `MetaLoadout`/`GameFeel`): trail color in
  `bullet_component`, core/trim in `player_component`, grid color in
  `arena_component`. **Guardrail: cosmetics never touch `GameBalance`/`BulletStats`** — pure
  render layer, so they're fair in every mode.
- **Achievements** (24, `features/achievements/domain/achievement_catalog.dart`):
  in-app definitions; ids + coin rewards mirror the backend's validation catalog
  exactly. Evaluated locally after each run against lifetime stats. **Unlock and
  claim are separate** — claiming grants the coin reward (ledger) and emits the one
  `achievementUnlock` sync event.
- **Leaderboards**: cache-first (Drift) with last-synced + pinned player rank;
  the cubit emits the cached board instantly, refreshes in the background, and on a
  failed (offline) refresh keeps the cache up with an **offline indicator** (`cloud_off`
  + "Offline · last synced …") rather than erroring. The cache is **period-aware**:
  it's keyed by the real period (`leaderboard_period.dart` mirrors the backend's
  `LeaderboardPeriod` — `yyyy-MM-dd` / ISO `yyyy-Www` / `alltime` / `dc:yyyy-MM-dd`),
  so a board from a previous period (after a UTC day/week rollover) is treated as
  no-cache-for-today instead of being shown as current. Read-only — submission is the
  run-end `scoreSubmit`/`challengeResult` outbox. Daily/Weekly/All-time/Daily-Challenge tabs.

## Trick-Shot Gallery (`features/game/presentation/trickshot/`)

A puzzle mode and the best teacher for the core mechanic: curated bounce puzzles (hit each
target with ≥ N ricochets), **no enemies/waves**. Levels are pure data
(`engine/trickshot/trickshot_level.dart` + `trickshot_catalog.dart`, referencing existing
arenas). Reuses the whole engine: `DeadbounceGame.trickShotLevel` makes `onLoad` skip
`waveRunner.startWave` and drop static `TrickShotTargetComponent`s (an `EnemyComponent`
subclass that rides the existing bullet sweep but gates `canBeDamagedBy` on
`bullet.bounces >= requiredBounces`). It's **fully isolated from the scored run path** —
`TrickShotPage` is its own `GameSessionGateway` with no-op `onWaveCleared`/`onRunEnded`
(so nothing hits runs/leaderboards/stats); completion fires `DeadbounceGame.onTrickShot
Complete`/`onTrickShotProgress` callbacks instead. Routes: `Routes.trickShot` (gallery) +
`Routes.trickShotRun/:id`; Home → "TRICKS" nav tile. Best-score persistence is a planned
fast-follow (v1 ships the ladder + per-clear shots-vs-par).

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
- **Offline session restore**: **first login needs internet** (the server provisions
  the user + mints the JWT), but every cold start after that is offline-capable.
  `_exchange` caches the `AuthUser` via `AuthLocalDataSource` (secure storage);
  `restoreSession()` returns that cached identity **with no network call** (falling
  back to a `FirebaseAuth.currentUser`-derived identity for pre-cache tokens), so the
  app stays logged in with zero connectivity. The old blocking `GET /auth/me` is gone
  from the boot path. The Deadbounce JWT is **stateless, 7-day expiry**:
  `AuthRepository.refreshSessionToken()` silently re-exchanges the current Firebase
  identity via `POST /auth/firebase` (works even when the old JWT has expired). It runs
  two ways — (1) `ApiClient` has an `onError` interceptor that, on a **401** (never on
  the `/auth/firebase` path, once per request, single-flight), refreshes and replays
  the original request, so sync self-heals after the token expires; (2) `AuthCubit`
  fires a background reconcile after an offline restore and **only signs out on an
  explicit identity rejection** (`SessionRefreshOutcome.identityRejected` — account
  disabled/deleted or backend 401/403), never on a network error.

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
                   leaderboards, profile, settings, statistics, about, home, splash
```

**Living backdrop, app-wide:** `core/widgets/animated_arena_background.dart`
(`AnimatedArenaBackground`) is the shared cinematic background used by **every**
screen — home, meta screens (`MetaScaffold`), auth (`AuthScaffold`), loading
(`DbLoadingScene`), and the game overlays: the arena gradient + a neon
perspective floor grid scrolling toward the viewer, two seamless ricochet tracer
bullets bouncing off the edges, drifting enemy silhouettes, rising embers, and a
vignette for contrast. Render it **outside `SafeArea`** (full-bleed behind the
dynamic island/camera) with content inside `SafeArea`.

**Home — "living arena" menu** (`features/home/`): a cinematic, personalized
main menu over the shared `AnimatedArenaBackground`. `HomeCubit`
loads an offline-first `HomeSummary` (name, best score, kills, cached all-time
rank, western tier) for the identity bar + BEST/KILLS/RANK chips; the hero is
the `DbLaunchButton` wrapped in `HeroOrbRig`; a neon-sign `NeonWordmark`; a daily
challenge event card; and a one-row nav (Boards / Awards / Stats / Guide). Blocks
animate in on a staggered entrance via **`flutter_animate`**. Must stay
**no-scroll / no-overflow** (responsive clamps). Nav targets: Boards, Awards,
**Statistics**, **How to Play**. `statistics` reads lifetime aggregates + the
per-enemy kill breakdown from `statsDao` (its own `StatisticsRepository`).
`about` holds the How-to-Play rulebook and Credits (author + `https://pranta.dev`,
`url_launcher` with clipboard fallback) — Credits is currently unlinked.

`app.dart` is the composition root: app-wide graph (auth, ApiClient) built once;
`SessionDependencies` (per-account DB + sync engine + game-data repositories) built
by `_SessionScope` when auth lands on a uid, torn down on sign-out. Read it in
post-auth screens via `context.sessionDependencies`.

## Key decisions

- 3-anchor tap-dash movement (documented above).
- Achievement & challenge definitions ship in-app; only results/unlocks sync.
- One Drift file per account; period-keyed leaderboards on the backend.
- Generated `*.g.dart` (Drift) is **gitignored**, not committed — regenerate with
  `dart run build_runner build --delete-conflicting-outputs` after a fresh clone or
  Drift schema change. (`flutter analyze` is still the commit gate.)
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

## Audio

Real SFX via `flame_audio` (`FlameAudioSoundManager`) behind the `SoundManager`
seam — hot sounds (fire, bounce variants, kill, coin) use AudioPools; the rest
play one-shot. Clips live in `assets/audio/` and preload during the pre-game beat;
the Settings sound toggle gates playback; load failures fall back to silence.
Wall bounces climb in pitch with the bounce count (`bounce_1/2/3.wav` via
`Sfx.bounceFor`).

**Music**: `core/audio/music_manager.dart` (`MusicManager`, a `FlameAudio.bgm`
wrapper) plays one looping track at a time — `menu` on Home, `combat` on a normal
wave, and `boss` on Warden waves (swapped in `WaveRunner.startWave` via
`WaveDefinition.hasBoss`, back to `combat` on the next wave). Loops live at
`assets/audio/{menu,combat,boss}_loop.wav`. Gated by the **Music** settings toggle
(`AppSettings.musicEnabled`) and **gracefully silent if a track file is absent**.
Still open (optional): wiring `Sfx.uiTap` into menu buttons.

## Settings

`features/settings/` — `AppSettings` (Equatable) persisted in the Drift key-value
`settings` table via `SettingsRepository`(+impl); `SettingsCubit` toggles emit-then-
persist. Beyond audio (sound/music/haptics), it carries **game-feel/accessibility**
prefs, all wired to real behavior and read once in `GameSessionCubit.startRun()` into
an immutable **`GameFeel`** (`features/game/presentation/game/game_feel.dart`) handed
to `DeadbounceGame` (like the meta loadout, kept OUT of `GameBalance`):
`screenShakeEnabled`/`hitStopEnabled` gate `JuiceController.addTrauma`/`hitStop`;
`aimGuideEnabled` gates `trajectory.visible` in `InputController`; `combatTextEnabled`
gates the four popup spawn sites (bounce counter, chain label, Warden CLANG, Ironhide CLANG);
`particleQuality` (`ParticleQuality.low/medium/high` → budget 250/600/1200) feeds the
`ParticleFactory` budget. The screen (`settings_screen.dart`, over `MetaScaffold`) is
sectioned AUDIO / GAME FEEL / DATA & SYNC / ACCOUNT / ABOUT / DANGER ZONE /
DIAGNOSTICS(debug). DATA & SYNC surfaces the `SyncStatusNotifier` with Sync-now /
Retry-failed (`syncWorker`). ABOUT links How-to-Play / Credits / pranta.dev
(`core/util/open_external_link.dart`, shared with Credits) + a dynamic version via
`package_info_plus`. **DANGER ZONE → Clear local data** calls
`SessionDependencies.clearLocalData()` → `AppDatabase.clearGameData()` (wipes
gameplay/account tables, **preserves `settings`**) then re-pulls the server snapshot
in place **without signing out** (guest-safe); unsynced changes are lost.

## Logging (Talker)

End-to-end logging via **Talker**, **debug-only** (zero cost in release):

- **`AppLogger.talker`** (`core/logging/app_logger.dart`) is the one global instance,
  configured `enabled: kDebugMode` — so every `info/warning/error/handle` call is a
  no-op in release and needs no call-site guard.
- **Automatic** (wired in `main.dart` / `api_client.dart`, all behind `kDebugMode`):
  `TalkerBlocObserver` logs every Cubit state change/error; `TalkerDioLogger` logs
  every HTTP request/response/error; `FlutterError.onError` +
  `PlatformDispatcher.onError` capture uncaught framework/platform errors.
- **Manual** instrumentation at the key boundaries — sync engine (`core/sync/*`),
  the run-end transaction (`runs_repository_impl`), game session, auth, economy,
  streak, achievements, leaderboards, audio, config. Silent `catch (_)` blocks were
  converted to `catch (e, st) { AppLogger.talker.handle(e, st, '[area] …'); … }`
  (behavior unchanged — they just log now).
- **Convention:** prefix messages with a short area tag, e.g. `[sync]`, `[run]`,
  `[auth]`, `[game]`, `[economy]`, `[streak]`, `[achievements]`, `[leaderboard]`,
  `[audio]`, `[config]`.
- **Viewer:** debug builds only — Settings → **Diagnostics → View logs** opens
  `TalkerScreen` (`/logs` route, registered only under `kDebugMode`). No Riverpod in
  this app, so `talker_bloc_logger` is the state-management integration (not
  `talker_riverpod_logger`).

## Legal & consent (privacy / terms) — keep in sync with features

First-launch legal gate: `assets/legal/{privacy,terms}.md` are shown in a
two-tab consent screen (`features/legal/`, rendered by a small in-house
markdown widget) **after** the boot splash and **before** login. Acceptance is
device-level in `SharedPreferences` (pre-auth, per-install), gated by the
GoRouter redirect; the read-only viewer is linked from Settings → About.

`lib/core/legal/legal_documents.dart` holds `LegalDocuments.version` — the
single source of truth. **Bump it (and the matching `**Version N**` line in
BOTH markdown files) and every user is re-prompted to accept on next launch.**

> **RULE — when you ship or change a feature, check whether the Privacy Policy /
> Terms / Refund need updating.** If a feature changes what data is collected,
> how it's used, third-party SDKs, virtual-goods/payment behavior, etc., update
> the relevant `assets/legal/*.md`, **bump `LegalDocuments.version`**, and
> **re-copy the files to `G:\MyProjects\privacy-project\Projects\deadbounce\`**
> (privacy.md, terms.md, refund.md) so the hosted copies stay byte-identical to
> what users accept in-app, then commit that repo. Refund.md is hosted-only (not
> bundled in the app). The big one is monetization — see the
> `monetization-legal-checklist` memory.

## Intentionally stubbed / next phase

- **Account linking** (guest→Google): the architecture supports it (per-account
  file survives, `accountLinked` event exists), but the Profile CTA currently shows
  "coming soon". Real `linkWithCredential` is the next step. **REMINDER (deferred
  2026-06-27 settings audit):** this is the single remaining placeholder on the
  Settings→Profile path — everything else there is fully wired. Pick this up when
  ready: implement `linkWithCredential` (Google first, Apple after), surface
  success/error UX on the Profile CTA, and emit the existing `accountLinked` sync
  event.
- **Apple Sign-In**: button placeholder (Phase 1).
- Final art (the logo is a styled Material icon, default launcher icon),
  shop/monetization (the ledger prepares for it), PvP.
