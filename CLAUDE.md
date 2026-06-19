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

**Difficulty philosophy (do not undo): the first 3 waves must feel trivial** —
only slow Drifters with generous spacing — then difficulty stays near-flat early
and accelerates later. Enemy introductions: Drifter w1, Charger w4 (long, obvious
telegraph), Splitter w6, Turret w8, **first Warden w10** (kept late so the early
game is kind; every 5th thereafter — 15, 20, …). Waves 1–15 are authored
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
  seed (`engine/challenge/`), identical worldwide and offline — forced enemy type,
  +wall damage, heart cap, score multiplier, or random-dealt upgrades. Scores submit
  to a separate daily-challenge board.
- **The Gunsmith** (`features/meta/`): the coin SINK / permanent meta-progression.
  Spend coins on tiered perks that apply to **every normal run** (not daily
  challenges — those stay fair): Reinforced Heart, Iron Resolve, Quick Hands, Keen
  Eye, Lucky Strike, Second Wind. **Guardrail: perks never add flat bullet damage**
  (that would break "no damage till it bounces") — survivability/utility/economy only.
  Catalog in Dart (`meta_catalog.dart`); ownership LEVEL per perk in the local
  `meta_upgrades` Drift table (local-only for now; the coin *spend* syncs via the
  ledger as `shopPurchase`). `RunModifiers.addPermanent` pre-loads the perk as a
  modifier (reusing existing card modifiers: heart_container/quickdraw/longer_sight/
  coin_magnet) without counting it as a wave pick; permanent stacks still respect each
  card's max-stacks cap. Applied in `game_session_cubit.startRun` via `MetaLoadout`.
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

## Audio

Real SFX via `flame_audio` (`FlameAudioSoundManager`) behind the `SoundManager`
seam — hot sounds (fire, bounce variants, kill, coin) use AudioPools; the rest
play one-shot. Clips live in `assets/audio/` and preload during the pre-game beat;
the Settings sound toggle gates playback; load failures fall back to silence.
Wall bounces climb in pitch with the bounce count (`bounce_1/2/3.wav` via
`Sfx.bounceFor`).

**Music**: `core/audio/music_manager.dart` (`MusicManager`, a `FlameAudio.bgm`
wrapper) plays one looping track at a time — `menu` on Home, `combat` on run start
(`boss` reserved). Gated by the **Music** settings toggle (`AppSettings.musicEnabled`)
and **gracefully silent if a track file is absent**, so the game runs fine before the
loops exist. Add `assets/audio/menu_loop.mp3` / `combat_loop.mp3` / `boss_loop.mp3`
to bring it to life. Still open (optional): the boss-loop swap on Warden waves, and
wiring `Sfx.uiTap` into menu buttons.

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

## Intentionally stubbed / next phase

- **Account linking** (guest→Google): the architecture supports it (per-account
  file survives, `accountLinked` event exists), but the Profile CTA currently shows
  "coming soon". Real `linkWithCredential` is the next step.
- **Apple Sign-In**: button placeholder (Phase 1).
- Final art (the logo is a styled Material icon, default launcher icon),
  shop/monetization (the ledger prepares for it), PvP.
