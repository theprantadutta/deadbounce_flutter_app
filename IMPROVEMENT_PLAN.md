# Deadbounce — Gameplay Improvement Plan

> Written 2026-07-06 after a full four-track analysis of the codebase (core game feel,
> enemy/wave design, UI/UX, meta/economy). This is the living roadmap: phases are done
> **in order, one at a time**, each verified with `flutter analyze` + `flutter test`
> and a real play-test before starting the next. Check items off as they ship.

---

## The Diagnosis (why the game felt boring)

The engineering is strong — offline-first sync, clean modifier pipeline, deterministic
seeded challenges. The *game design* underneath was slow, safe, and static:

1. **Nothing threatened the player.** Enemies moved 26–58 px/s in a 1280px arena
   (15–30s crossings), speed scaling hard-caps at ×1.7 forever, the boss has no
   attacks, and generous i-frames + far-away spawn zones made death nearly impossible
   for an attentive player. You died of attrition and boredom, not skill pressure.
2. **Kills had no punch.** Single kills (the most common event) had zero hit-stop;
   the moment a bullet went lethal (first bounce — the core rule!) had no feedback.
3. **Chains — the game's stated identity — rarely happened.** Same-bullet kills within
   1.4s require enemy density that slow, staggered, blob-stacking spawns never created.
4. **The ricochet hook is starved.** 2 of 3 arenas are bare boxes; only TWIN POSTS has
   interior geometry. The aim preview showed 2 of 8 possible bounces.
5. **Difficulty = HP sponge.** Late-game enemies become bricks (wave 50 Ironhide:
   57 HP vs. max 8 dmg/bullet) instead of becoming dangerous.
6. **The meta is a treadmill to nowhere.** ~6,500 lifetime coin sink vs. 3,770 coins
   from achievements alone; nothing unlocks by playing — all arenas/enemies/cards are
   available from run 1. After 5 runs a player has seen everything.
7. **Flow killers.** 1.3s hard loading gate on every run/retry, full engine pause +
   mandatory upgrade pick after *every* wave, dead tap inputs.

**Design north star (the user's vision):** *clever, decisions-on-the-fly, but
accessible.* Reward smart play, never punish slow reflexes. Readable telegraphs stay
sacred; tedium is the enemy, not the player.

---

## ✅ Phase 1 — Make it feel alive (SHIPPED 2026-07-06)

All client-side. Analyze clean, 127/127 tests pass.

- [x] **Enemy speed retune (+~60%)** — Drifter 58→95, Charger roam 46→75, Splitter
      42→70, Powderkeg 38→60, Sawbones 34→56, Mirror 32→52, Ironhide 30→46,
      Warden 26→36, turret projectile 140→190 (`game_balance.dart`). Arena crossings
      now ~10s instead of ~21s. Telegraphs untouched so readability is preserved.
- [x] **Hit-stop on every kill** — new `juice.hitStopKill` (30ms); multi-kill 45ms and
      Warden 60ms unchanged (`juice_controller.dart`).
- [x] **"ARMED" popup on the first bounce** — the go-lethal moment made visible
      (`popup_text_component.dart`, `bullet_component.dart`).
- [x] **Enemy separation steering** — seeking enemies push apart instead of stacking
      into one blob; groups arrive as threadable arcs
      (`EnemyComponent.seekPlayer`, tunables in `GameBalance.I.enemies`).
- [x] **Waves 1–3 densified** — 3/4/5 drifters with tighter staggers (was 2/3/4).
      Still trivial in threat, no longer empty (`wave_table.dart`).
- [x] **Pre-run gate 1300ms → 350ms** — paid on every run AND retry
      (`game_session_cubit.dart`). Keep it short forever.
- [x] **Dead-input dash fix** — tapping your own zone hops one anchor toward the tap
      side; a tap is never a silent no-op (`input_controller.dart`).
- [x] **Dash i-frames 0.15s → 0.35s** — the dash now actually functions as a dodge.
- [x] **Aim preview 2 → 3 bounces** (`player.previewBounces`).

**Play-test questions before Phase 2:** Do waves 1–8 feel alive now? Is the speed bump
too much anywhere (Chargers especially)? Does ARMED read clearly or spam?

---

## Phase 2 — Make it dangerous (client-only) — SHIPPED 2026-07-06

Goal: the player should die because they made a bad decision, not because they got
bored. Pressure creates the *need* for clever shots. **All client-only. Analyze
clean, 137/137 tests. Awaiting play-test.**

- [x] **Give the Warden real attacks.** (SHIPPED) Two attacks, both telegraphed:
      (1) a periodic **radial burst** of interceptable projectiles (`warden.attack*`
      tunables; ≥0.6s charge with a swelling warning ring + spoke hints; the Warden
      holds still while winding up so it reads); (2) **summons small Drifters on
      phase break** (`warden.summonOnPhaseBreak`) so the shield-down punish window is
      a real risk/reward. Reuses `EnemyProjectileComponent` (now parameterized by
      cause/color/radius) so bursts are dodgeable AND shootable at any bounce count.
- [x] **Add 1–2 fast enemy archetypes.** (SHIPPED both) **Skitter** — fast (150),
      fragile (1 HP), sharp *rhythmic* weave; the threat is speed, dash i-frames
      always beat it (intro w12). **Lancer** — hangs at standoff range, telegraphs a
      locked horizontal lane (drawn during wind-up), then strafes straight across the
      arena: a fast MOVING ricochet target and a dodgeable threat, 3 HP (intro w14).
      New `SkitterBalance`/`LancerBalance`, enum + spawn_director + stats + death-beat
      wired; both appear in endless scaling.
- [x] **Cluster spawns to enable chains.** (SHIPPED) `SpawnGroup.formation`
      (`SpawnFormation.scattered`/`line`/`wedge`/`cluster`, `wave_definition.dart`);
      pure layout math in `spawn_formation.dart` (unit-tested); `SpawnDirector.
      planFormation` picks one anchor zone + lays members out clamped in-arena;
      `WaveRunner` passes each member's pre-planned slot to `spawnTelegraphed`.
      Fodder (Drifter/Splitter) groups in the authored table + endless scaling now
      spawn as threadable shapes; wave 3 is the first line (teaches "one bullet,
      many kills"). Scattered stays the default → zero change to non-fodder groups.
      Analyze clean, 132/132 tests. **Play-test:** do chains actually happen now,
      and does the line read as threadable rather than a wall?
- [x] **Rebalance late scaling: tension, not sponge.** (SHIPPED) `hpGrowthPerWave`
      0.08→0.055, `hpCurveExponent` 1.3→1.2 (no more damage-immune bricks);
      `speedGrowthCap` 0.6→1.2, `speedGrowthPerWave` 0.015→0.02; count pressure
      `extraCountPerWave` 0.8→1.1. Late enemies are now fast + numerous, not tanky.
- [x] **Charger fix-up:** (SHIPPED) recover phase now renders as a groggy stagger
      (dimmed body, sway, orbiting dizzy sparks) so the punish window is legible.
- [x] **Powderkeg fuse:** (SHIPPED) fuse 0.6→0.5 + blast radius 78→96 so the
      "don't kill it point-blank" decision bites (still a full dash window).
- [x] **Wave-clear flow:** (SHIPPED) draft every wave until 5, then every 2nd wave
      (`waves.draftEveryWaveUntil`/`draftCadence`, `WaveScaling.shouldDraft`). Score/
      coins still reward every clear; only the interrupting picker is gated.

**Balance guardrails (held):** first 3 waves stay drifters-only and trivial; every new
threat telegraphs ≥0.6s; contact damage stays 1 heart; i-frames stay generous.

**Play-test questions before Phase 3:** Is the Warden fun to fight now (burst readable,
summons fair)? Do Skitters pressure without feeling cheap? Does the Lancer read as a
ricochet target? Is late-game "fast + many" instead of "spongy"? Does the every-2-waves
draft feel better or does power growth feel too slow?

> **Backend note (not blocking):** new enemy ids `skitter`/`lancer` flow into the
> `statsDelta.enemy_kills` map on sync (additive keys, like the roster additions
> before them). No backend catalog validates enemy ids, so this stays client-only per
> the phase scope — but confirm the server tolerates unknown keys if it ever starts
> validating them.

---

## Phase 3 — Feed the ricochet hook (client-only) — SHIPPED 2026-07-06

Goal: the bounce fantasy needs geometry and toys. **Analyze clean, 153/153 tests.
Awaiting play-test.**

- [x] **6 new arenas** (SHIPPED, `arena_catalog.dart`): CROSSFIRE (diamond island),
      SWINGING DOORS (staggered half-walls), THE PINCH (hourglass), THE CHUTE
      (corridor), THE WISHBONE (chevron band), FOUR CORNERS (2×2 posts). 3→9 arenas;
      the per-run pick now draws from all 9. Each passes the trajectory-parity keystone.
- [x] **Arena variety per run** (SHIPPED, partial): the run arena is picked from the
      full 9-arena pool, so variety is way up. **Deferred:** in-run rotation every ~5
      waves (needs live segment/solver rebuild) — pairs with Phase 4 unlockable slots.
- [x] **22 trick-shot levels** (SHIPPED, `trickshot_catalog.dart`, 5→22): span all new
      arenas, escalating; several explicit **chain teachers** (2–3 marks, par 1 —
      "one bullet, both marks") since the tutorial never covers chaining. A catalog
      test asserts no target is buried in an obstacle and every requiredBounces is
      reachable.
- [x] **8 new upgrade cards** (SHIPPED, 12→20): LONG FUSE (+lifetime), GREASED LEAD
      (+speed/bounce), RIFLING (+max bounces), FLASHPOINT (deep-bounce AoE burst),
      CHAIN LIGHTNING (chain-kill forks a lethal bolt), SHRAPNEL (armed kill sprays 3
      lethal shards), FAN FIRE (tri-shot), VENGEANCE (retaliation burst after a hit).
      Transform-behavior, not stat bumps; all with new modifiers + tests. Bonus UI:
      cards now show their **mechanical effect** line (not vibes-only) and common
      borders are legible (ink100).
- [x] **Rarity weight pass + pity** (SHIPPED): weights 100/40/12 → **100/50/22**; a
      **pity rule** guarantees a rare+ after two straight all-common drafts
      (`UpgradeDeck.draw3(guaranteeRarePlus:)`, driven by a counter in the game).
- [x] **Daily-challenge templates** (SHIPPED, 6→11, using existing safe config):
      QUICKSILVER (Skitters, ×2), SHOOTING GALLERY (Lancers), GLASS CANNON (1 heart +
      walls +2), TIN CAN ALLEY (Ironhides). **Deferred to Phase 4** (needs new engine
      mechanics AND `ScoreSanityValidator` lockstep): the core-rule benders — "2
      bounces to arm", "mirror walls (+bounce credit)", "chain window halved / score
      tripled". Kept out of Phase 3 to keep it client-only.

---

## Phase 4 — Give the meta a soul (client + .NET backend together) — SHIPPED 2026-07-06

Goal: coins must stay meaningful forever, and runs 6–50 must keep revealing new toys.
**Backend is local at `../deadbounce-dotnet-api`; changes are in lockstep.** Backend gate
`dotnet build` = 0 errors; client analyze clean + 159 tests. **4A–4E all shipped**; only the
deferred rule-bender daily challenges remain (need new engine mechanics). Awaiting play-test.

- [x] **Retune `ScoreSanityValidator`** (SHIPPED, 4A, backend-only). Loosened for the
      faster/denser Phase 2/3 game: 6s→4s/wave, 40→90 kills/wave, 600→1000 score/kill,
      12k→24k score/wave, 5M→10M score. (Doc prose in backend CLAUDE.md updated too.)
- [x] **Achievement pass** (SHIPPED, 4B, client+backend lockstep). 5 skill tiers added
      (24→29): rampage (chain ×6), dead_center (8-bounce kill), flawless (wave 15 no-hit),
      exterminator (1000 kills), the_abyss (wave 50). Ids+rewards mirrored in
      `AchievementDefinitions.cs`.
- [x] **Fix the Gunsmith's flatness** (SHIPPED, 4C, client+backend lockstep). Fixed the
      Lucky Strike blurb bug (+15%→+25%, matches the ×1.25 modifier). Added two
      build-defining perks (no flat bullet damage): **Gunfighter's Memory** (+0.15s chain
      window/level, wired through `ScoreSystem.chainWindowBonus`) and **Opening Hand**
      (start with a free RARE card). `MetaPerkDefinitions.cs` mirrors the ids+maxLevels.
- [x] **Permanent coin sinks** (SHIPPED, 4D). **Draft reroll**: escalating in-run cost
      (`economy.draftRerollBaseCost/Step`, `CoinReason.draftReroll`, wallet spend, reroll
      button on the picker, normal-runs-only). **Continue-once-per-run**: a fatal hit on a
      normal run routes through `DeadbounceGame.onWouldDie` → cubit offers a paid buy-back
      (`SessionAwaitingContinue` + `ContinueOverlay`); buying revives at 1 heart + 2s
      i-frames (`player.reviveWithGrace`, mirrors the proven Last Stand restore) and
      resumes; declining/unaffordable ends the run through the SAME idempotent `endRun`
      path (no double-record). `CoinReason.continueRun`, disabled in challenges/tournaments
      (`challenge == null` gate). Backend `CoinTxnProcessor` sanity-gates both new reasons
      (negative spend ≤ 5000).
- [x] **Unlock curve** (SHIPPED, 4E — no migration needed). Implemented as a **pure
      function of lifetime stats already tracked+synced** (`UnlockCatalog` over best wave /
      runs played / lifetime kills) instead of a new synced table — same "content revealed
      by play" feature, reinstall-safe for free, zero DB risk. The 6 Phase-3 arenas + 8
      Phase-3 cards gate behind escalating milestones; the starting kit (3 arenas + 12
      cards) is always open. Gating applies to **normal runs only** (daily/tournament use
      the full catalog to stay identical worldwide): `GameSessionCubit.startRun` computes
      the unlocked set → gates the arena pick + `UpgradeDeck.draw3(unlockedCardIds:)`. A
      "STILL TO UNLOCK" section on the Statistics screen shows the next milestones.
- [ ] **Deferred rule-bender daily challenges** (from Phase 3): "2 bounces to arm", "mirror
      walls (+bounce credit)", chain-window benders — need new engine mechanics + the
      `ScoreSanityValidator` headroom (now looser, so more room).

---

## Bug fixes (do opportunistically, some need backend lockstep)

- [x] **Lucky Strike blurb fixed** (Phase 4C): `coin_magnet` is `maxStacks: 3`, matching
      the perk's `maxLevel: 3` (so L3 *does* apply — the "no-op" was stale/already fine);
      the blurb "+15%/level" was wrong (the modifier is ×1.25) — corrected to "+25%/level".
- [ ] **Wave progress HUD under-counts** — Splitter children aren't in the
      denominator (`wave_runner.dart`), so "N left" is wrong on Splitter waves.
- [ ] **`EnemyType.smallDrifter` is dead code** — nothing spawns it; Splitter
      children bypass the enum (`spawn_director.dart`). Remove or use it.
- [ ] **Turret silently floats** when no wall slot is free (`turret_enemy.dart`) —
      give it a fallback visual or make it claim the nearest occupied-adjacent point.
- [ ] **Sawbones comment lies** — "keeps a gentle distance" but it plain-seeks
      (`sawbones_enemy.dart`). Either implement kiting (better: it *should* hang
      back — it's a priority target) or fix the comment.
- [ ] **Warden phase-HP rounding drift** — `phaseHp` and total HP `.ceil()`
      independently (`warden_enemy.dart`); display can momentarily read over/under.
- [ ] **Splash busy-wait** — `_onAuthenticated` spin-polls every 16ms
      (`splash_page.dart`); await a future/stream instead.

---

## UI/UX improvements (fold into whichever phase touches the screen)

### In-game
- [ ] **Wave banner ↔ chain meter collision** — both occupy the top-center band
      (`hud_overlay.dart`); a wave transition during an active chain overlaps. Offset
      the banner or suppress it while a chain is live.
- [ ] **Upgrade cards show flavor text only** — add the mechanical effect and current
      stack count ("Split Shot ×1 → ×2") to `upgrade_picker_overlay.dart`. The core
      progression decision is currently vibes-only.
- [ ] **Common-rarity card contrast** — grey-on-dark border is nearly invisible next
      to the glowing rare/epic cards.
- [ ] **HUD sizing pass** — hearts 20px, coin icon 13px, readiness pips 26px are
      small for a one-thumb action game on a glowing background.
- [ ] **Readiness beat at run start** — wave 1 spawns the instant the arena renders;
      add a ~0.8s "WAVE 1" settle beat before the first telegraph.
- [ ] **Instant same-arena retry** — RIDE AGAIN re-mounts the whole game and rerolls
      the arena; offer a fast restart that reuses the loaded engine.
- [ ] **Review prompt timing** — the native rate-app sheet can interrupt the results
      screen (`game_page.dart`); defer it to the Home screen return.

### Menus / flow
- [ ] **Home density** — ~13 tappable targets dilute the PLAY hero; consider
      collapsing the 4 promo cards into a single rotating "featured" card.
- [ ] **Trick-shot is buried** — the best teacher of the core mechanic is a tiny
      "TRICKS" nav tile; promote it for new players (or gate the first daily
      challenge behind clearing 3 trick-shots — teaches chaining AND surfaces it).
- [ ] **Tutorial never teaches chaining or the upgrade draft** — the two systems that
      define the game. Add one hands-on chain step (2 targets, 1 bullet) and a mock
      draft step (`tutorial_steps.dart`).
- [ ] **Cross-linking** — Awards/Boards/Gunsmith/Outfitter are back-button silos;
      add contextual links (results screen → the achievement you nearly unlocked,
      Gunsmith ↔ Outfitter tabs).

### Art / identity (placeholder debt)
- [ ] The logo is `Icons.airline_stops_rounded`; the launcher icon is Flutter's
      default; the launch orb shows a **rocket** (`Icons.rocket_launch`) in a
      neo-western game. Replace with bespoke marks first — highest identity value
      per asset.
- [ ] Every upgrade/enemy/perk icon is a stock Material icon + glow. A single
      commissioned icon set (or consistent custom-painted glyphs) would delete the
      "template" feel. Do enemies + upgrade cards first (seen mid-game).
- [ ] Wire `Sfx.uiTap` into menu buttons (noted as open in CLAUDE.md).

---

## Explicitly deferred / next-phase (pre-existing list, unchanged)

- Account linking (guest → Google `linkWithCredential`), then Apple Sign-In.
- Real-money IAP / subscriptions (ledger + legal docs already prepared).
- PvP.

---

## Working agreement

- One phase at a time; play-test between phases; tuning lives in `GameBalance`
  (debug panel) so numbers can be felt before being promoted to defaults.
- `flutter analyze` clean + `flutter test` green before anything ships.
- Any feature that changes data collection, purchases, or virtual goods → re-check
  `assets/legal/*.md` + bump `LegalDocuments.version` (see CLAUDE.md rule).
- Backend catalogs (achievements, perks, cosmetics, sanity validator) must move in
  lockstep with client catalogs — never let them drift.
