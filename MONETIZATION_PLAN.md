# Deadbounce — Monetization Plan

> Written 2026-08-04 after a full analysis of the Flutter client + .NET backend.
> Living roadmap: phases ship **in order, one at a time**, each verified with
> `flutter analyze` + `flutter test` (and `dotnet build` for backend phases) and a
> real play-test before the next starts. Check items off as they ship.
>
> **Decisions locked in (2026-08-04):** ads = rewarded + one minimal banner +
> *very rare* interstitials. Sequencing = foundation first. Products = Remove Ads,
> premium cosmetic packs, coin packs, and a seasonal Bounty Pass.

---

## The Diagnosis

The monetization **chassis** is already built to a high standard — the engine is missing.

**What exists and is production-grade:**

- A real coin **ledger** (`coin_ledger` + `CoinReason`, offline-first, server-mirrored,
  idempotent by txn uuid) — not a mutated int. This is the hard part and it's done.
- Two coin **sinks**: The Gunsmith (4,700 lifetime) and The Outfitter (3,100 lifetime).
- Two **repeatable** in-run sinks: draft reroll (`30 + 30n`) and continue-on-death (500).
  Both already have overlay UI — these are the natural rewarded-ad slots, pre-built.
- Tournaments with coin entry fees + server-finalized, single-claim reward payouts.
- Legal docs (`privacy` / `terms` / `refund`, v2) already written **forward-looking**
  for IAP and subscriptions.
- Backend already references `Google.Apis.AndroidPublisher.v3` and hard-fails at boot
  if `google-play-service-account.json` is missing — the credential plumbing is live,
  the package is simply **unused**.
- `in_app_review` (gated at 3 runs) and `in_app_update` wired.

**What blocks real money:**

1. **Zero analytics.** No `firebase_analytics`, no Crashlytics. D1/D7 retention, session
   length, quit points, ARPDAU — all invisible. Monetizing blind.
2. **The coin economy is too shallow to sell into.** Total permanent sink is **7,800**
   coins; achievements alone pay out **5,770** (29 × avg 199); a wave-10 run yields
   ~450–500 (`coinPerKill 3` + 40% × 4 drop + 15/wave + chain bonus); login streak adds
   25–300/day. **A player owns everything permanent in ~15–20 runs.** A coin pack today
   sells a two-hour shortcut into a dead shop. (`IMPROVEMENT_PLAN.md` already called
   this "the meta is a treadmill to nowhere.")
3. **The coin ledger is client-authoritative.** `CoinTxnProcessor.cs:23` accepts any
   `adjustment` up to ±10M. Correct while coins are free — **fatal** once coins cost
   money. The right pattern already exists in this codebase (achievement rewards and
   tournament payouts are credited *by the server* from its own catalog); it just
   needs to cover purchased and ad-granted currency.
4. **No entitlement model server-side.** No product catalog, no `PlayerEntitlement`,
   no receipt verification, no restore path. Play **requires** restore to work.
5. **Guest accounts can't be linked.** The Profile CTA still says "coming soon."
   Real money on an unrecoverable account = refunds and 1-star reviews. Hard prereq.
6. **`privacy.md:86` explicitly promises no ads** — *"We do not integrate third-party
   advertising networks, and the App does not show ads."* Shipping ads means rewriting
   it, bumping `LegalDocuments.version` (re-prompts every user), re-copying to the
   hosted `privacy-project` repo, updating Play Data Safety, adding the `AD_ID`
   permission, and shipping a UMP consent flow.

**North star:** monetize the *depth* players already love, never the core loop. The
existing guardrails hold, verbatim: **perks never add flat bullet damage**, **cosmetics
never touch `GameBalance`/`BulletStats`**, and **daily challenges + tournaments stay
perk-free and identical worldwide**. Nothing purchasable may ever violate those three.

---

## ✅ Phase 0 — Instrumentation (SHIPPED 2026-08-04)

You cannot tune what you cannot see. Analyze clean, 172/172 tests pass, debug APK builds.

- [x] **Added `firebase_analytics` 12.4.6 + `firebase_crashlytics` 5.2.7** (both required
      raising `firebase_core` to 4.13.0). Android: `com.google.firebase.crashlytics`
      Gradle plugin 3.0.7 added, `com.google.gms.google-services` bumped 4.3.15 → 4.5.0
      (the old one predates AGP 9).
- [x] **The seam** (`core/analytics/`) — `AnalyticsService` (transport interface) +
      `NoopAnalyticsService` + `FirebaseAnalyticsService` + `LoggingAnalyticsService`,
      mirroring the `SoundManager` / `AppReviewService` pattern. Every impl swallows
      failures: telemetry never crashes a run.
- [x] **Debug builds upload NOTHING** — `main.dart` installs `LoggingAnalyticsService`
      under `kDebugMode`, so events are visible in Settings → Diagnostics → View logs
      while dev sessions stay out of production funnels. At indie volume a handful of
      dev runs visibly skews the exact D1/retention numbers this phase exists to
      measure. Crashlytics collection is likewise `!kDebugMode`.
- [x] **The taxonomy is typed, not stringly-typed** (`core/analytics/analytics.dart`):
      `Analytics` is a swappable static singleton (same shape as `GameBalance.I` /
      `MusicManager.instance`) exposing one method per event, so call sites can't
      misspell a name — **a renamed event silently resets its own history in Firebase.**
      Shipped events: `run_start`, `run_end`, `wave_cleared`, `upgrade_picked`,
      `draft_reroll`, `continue_offered`/`_bought`/`_declined`, `shop_view`,
      `shop_purchase`, `tournament_join`, `daily_claim`, `achievement_claim`,
      `trickshot_clear`, plus `screen_view`. Firebase's limits (25 params, 100-char
      string values) are enforced in `_clean` before send, and nulls are dropped.
- [x] **Every run event carries `mode`** (`normal` / `daily` / `tournament`) — normal
      runs are the only ones with perks, unlocks and coin sinks, so nearly every funnel
      needs that split.
- [x] **`continue_offered` fires even when the player can't afford it** — that
      population is exactly what a Phase 4 rewarded-ad continue would convert, so the
      baseline has to exist before the ad does.
- [x] **Screen views come from the navigator** — `AnalyticsRouteObserver` on the
      GoRouter, reading the route PATTERN (`dbPage` now sets `name: state.fullPath`) so
      `/tournament/:id` groups into one screen instead of one per id.
- [x] **Identity** — `Analytics.identify` sends the **backend user id**, never the
      Firebase uid or an email; `is_guest` / `best_wave` / `runs_played` user properties
      for cohorting (guest-vs-linked retention is the number that justifies Phase 1).
- [x] **Crashlytics on the release error path** — `FlutterError.onError` +
      `PlatformDispatcher.onError` were previously wired in debug ONLY, so uncaught
      framework/platform errors in release were simply lost. They now route to
      Crashlytics.
- [x] **Legal → version 3**: `privacy.md` gained a "Usage and diagnostic data" section
      and lists Google Analytics for Firebase + Crashlytics in §4;
      `LegalDocuments.version` bumped to 3 and all three `**Version N**` lines updated
      (this re-prompts every existing user for consent); all three re-copied to the
      hosted repo. **NOTE:** the hosted repo is at
      `G:\Personal\MyProjects\privacy-project\Projects\deadbounce\` — the path in
      `CLAUDE.md` was stale and has been corrected.
- [x] **Tests** — `test/core/analytics/analytics_test.dart` covers the no-op default,
      null-dropping, string clamping, the identity calls, and screen views.

**Still to do by hand (Console work, not code):**

- [ ] Update the Play Console **Data Safety** form: analytics + crash logs are now
      collected. Play requires this before the next release rolls out.
- [ ] Confirm events arrive: run a release build, check Firebase DebugView / Realtime.
- [ ] Decide on an **analytics opt-out toggle** in Settings → DATA & SYNC (see below).

**Definition of done:** a run produces a readable funnel in the Firebase console, and
you can answer "what wave do most players quit on?"

---

## ✅ Phase 1 — Account linking (SHIPPED 2026-08-04)

The hard prerequisite for real money. Analyze clean, 181/181 tests pass.
**No backend changes were needed** — `AccountLinkedProcessor` and the
`KnownEntityTypes` allowlist entry already existed; the client just never emitted
the event.

- [x] **Real `linkWithCredential` (Google)** — `AuthFirebaseDataSource.linkWithGoogle`.
      Google credential acquisition is now shared with `signInWithGoogle`, so both
      flows behave identically (same init, same cancellation semantics).
- [x] **The UID is preserved, which is the whole point.** The local database file is
      named `deadbounce_<firebaseUid>.sqlite`, so linking carries every run, coin and
      unlock across the upgrade with **no migration at all**.
- [x] **Forced token refresh after linking** — the cached ID token predates the link,
      so its claims would still describe an anonymous user when the backend inspects
      them.
- [x] **A failed link can never sign the guest out.** `AuthCubit.linkWithGoogle`
      deliberately does NOT reuse `_run` (which emits `AuthUnauthenticated` on
      failure — for a link that would throw the player out of a session they never
      left). Every failure path restores the exact prior state.
- [x] **Sealed `AccountLinkResult`** (success / cancelled / credentialInUse / failed)
      returned rather than thrown, so the CTA switches exhaustively and a missing
      branch is a compile error rather than a silent no-op on a screen that just took
      the player's account.
- [x] **The conflict case is handled properly, not swallowed.** If the chosen Google
      account already backs another Deadbounce account, two sets of progress exist and
      we cannot merge them. The UI names the account, spells out exactly what is lost,
      and offers KEEP GUEST PROGRESS / SIGN IN INSTEAD — the destructive option is
      explicit and confirmed, never automatic.
- [x] **Local truth + outbox in ONE transaction** — `ProfileRepository.markAccountLinked`
      flips `isGuest` and enqueues `accountLinked` together (the load-bearing
      offline-first invariant). Display name/photo are only overwritten when Google
      actually supplies one, so an existing name is never blanked.
- [x] **`ProfileCubit.refresh()`** reloads without the loading spinner, so the
      guest→linked flip updates in place instead of blanking a populated screen.
- [x] **Analytics**: one `account_link` event with a `result` dimension
      (success/cancelled/credential_in_use/failed) — one funnel, not four names.
- [x] **Tests** — `test/features/profile/account_link_test.dart`: the transaction
      writes both rows, the payload key the backend parses (`provider`) is asserted,
      `createdAt` survives the upsert, and an existing display name is preserved
      against both null and empty.

**Deferred from this phase, by design:**

- [ ] **Gate purchases on a linked account** — the buy sheet showing "Secure your
      account first". Belongs with Phase 2, because there is no buy sheet yet.
- [ ] Apple Sign-In — stays deferred until an iOS build is on the table.
- [ ] Email/password linking — Google covers the case that matters (one tap, no
      password to forget). Add later if support requests justify it.

---

## ✅ Phase 2 — Server-authoritative purchases (SHIPPED 2026-08-04)

Backend builds 0 errors; client analyze clean, **195/195 tests pass** (14 new).
The pipes are in. **No product is on sale yet** — Phase 5 is what turns these on,
and Phase 3 has to deepen the sink before coin packs mean anything.

### Backend (`Features/Purchases/`)

- [x] **`ProductDefinitions`** — the server catalog. **Google Play owns the PRICE;
      this file owns what a product GRANTS.** No price, coin amount or entitlement
      name is ever accepted from the client — a client that could name its own
      reward could buy the largest coin pack for the price of the smallest.
- [x] **`PurchaseReceipt`, PK = Play's `purchaseToken`** — the same natural-key trick
      `ProcessedSyncEvent` uses. The insert IS the idempotency check, so a replayed
      verify collides on the primary key and can never grant twice.
- [x] **`PlayerEntitlement`**, unique on `(UserId, EntitlementKey)` — keyed by
      CAPABILITY, not SKU, so a bundle and a standalone can grant the same thing
      without duplicating. Re-granting EXTENDS; a renewal reporting an earlier
      expiry can never shorten time already paid for.
- [x] **`GooglePlayPurchaseVerifier`** using the AndroidPublisher package the repo
      already referenced (and the service account already required at boot).
      Subscriptions use the **v2** endpoint; grace-period and on-hold still count as
      active (Google is retrying payment — yanking a paid feature mid-retry earns a
      refund and a one-star review).
- [x] **`POST /purchases/verify`** — catalog check → replay short-circuit → ask
      Google → only then grant. Coins are credited **server-side** into its own
      ledger as `iapCoinPack`. A pending purchase (cash/voucher/parental approval)
      is refused, not granted: it may never be paid. A Google outage returns **503**
      so the client retries instead of treating it as a failed purchase.
- [x] **`GET /purchases/entitlements`** + entitlements in `GET /sync/snapshot`, both
      through one shared `EntitlementProjection` — three copies of "is it expired?"
      is exactly how a player ends up seeing ads on one screen and not another.
- [x] **`CoinTxnProcessor` hardened.** It used to accept any `adjustment` up to ±10M.
      Now it runs on an allowlist with per-reason spend/earn bounds, rejects the
      server-only reasons (`iapCoinPack`, `adReward`) outright, and **drops
      `snapshotRestore`** — the client writes that seed straight to its local ledger
      and never syncs it, so accepting one would both double-credit the balance and
      hand a tampered client a legitimate-looking way to add millions.
- [x] Migration `PurchasesAndEntitlements`.

### Client (`features/store/`)

- [x] **`in_app_purchase` 3.3.0**, Drift schema **v7** (`entitlements` +
      `processed_purchases`).
- [x] **Play's "purchased" callback grants nothing.** It is treated as no more than
      "here is a token worth checking" — a patched client can fake it. Only the
      server's verdict unlocks anything.
- [x] **The purchase is NOT completed when verification fails.** Play redelivers an
      uncompleted purchase, which is exactly what should happen while the server is
      unreachable: the player paid, and the grant has to survive a bad network.
      Completing early would throw the receipt away.
- [x] **Pending-purchase recovery** — `storeRepository.start()` attaches the listener
      and replays unfinished purchases at session start. This is what saves someone
      who paid and then lost the app mid-flight.
- [x] **Coins mirror locally exactly once.** The server is idempotent per token, but
      the local ledger would happily credit again and drift the visible balance;
      `processed_purchases` plus a ledger id derived from the token stops it twice
      over. `WalletRepository.creditServerGranted` writes **no outbox event** —
      that missing sync is the entire point.
- [x] **Entitlements are REPLACED, never merged** — a refund, chargeback or lapsed
      subscription has to disappear locally too.
- [x] **Guests can browse but not buy.** A guest account dies with the install, so a
      purchase on one is unrecoverable. The store points them at Phase 1's linking
      instead of taking their money.
- [x] **Restore in two places** (Settings + the store screen) and in the snapshot.
      Google Play requires a working restore path.
- [x] Analytics: `purchase_started` + `purchase_result` — one funnel. Watch
      `verify_failed`: it means money changed hands and the server didn't confirm it.
- [x] Prices come from Play at runtime, already localised — never hardcoded.

### Still to do before anything can actually be sold

- [ ] **Create the SKUs in the Play Console** with ids matching `ProductDefinitions`
      exactly (`db_remove_ads`, `db_supporter_pack`, `db_coins_small/medium/large/huge`,
      `db_bounty_pass`). A typo means the player pays and verify rejects the SKU.
- [ ] Grant the service account **"View financial data"** in Play Console → Users, or
      every verification 401s.
- [ ] Add the `trail_supporter` cosmetic to both cosmetic catalogs (the supporter
      pack references it).
- [ ] `dotnet ef database update` on the deployment target.
- [ ] Test with Play **license testers** (real flow, no charge).
- [ ] Legal → present tense + version bump. **Batch this with the Phase 4 ads
      rewrite** so users aren't re-prompted twice.

---

## Phase 2 — original scope (kept for reference)

The single most important architectural decision here:

> **The client NEVER credits an IAP or ad-granted coin to the local ledger.**
> The server verifies the receipt, writes the ledger entry itself, and the client
> pulls it. This is a deliberate, documented **divergence from offline-first** — the
> same one already made for achievement rewards and tournament payouts.

### Backend (`Features/Purchases/`)

- [ ] `ProductDefinitions.cs` — static id → (type, coin grant, entitlement, cosmetic ids)
      catalog. Same shape and role as `AchievementDefinitions` / `CosmeticDefinitions` /
      `MetaPerkDefinitions`. **Google Play is the source of truth for price**; this file
      is the source of truth for *what the product grants*.
- [ ] `PurchaseReceipt` entity — **PK = Play `purchaseToken`**, which gives natural
      idempotency for free (exactly how `ProcessedSyncEvent` works).
- [ ] `PlayerEntitlement` entity — `(UserId, ProductId, Source, GrantedAt, OrderId,
      ExpiresAt?)`. `ExpiresAt` is nullable now and carries the Bounty Pass later.
- [ ] `POST /api/v1/purchases/verify` — `{ productId, purchaseToken }` →
      `AndroidPublisher.Purchases.Products.Get` (or `.Subscriptions.Get`) → validate
      package name + state + product id → dedupe by token → grant entitlement →
      **credit coin packs server-side** as a new `CoinReason.iapCoinPack` ledger row.
- [ ] `GET /api/v1/purchases/entitlements` — the restore endpoint.
- [ ] Add entitlements to `GET /sync/snapshot` so a reinstall restores them in the
      existing one-time hydration.
- [ ] **Harden `CoinTxnProcessor`** while you're in there:
      reject `adjustment` from clients outright; reject `iapCoinPack` and `adReward`
      from the client channel entirely (server-only reasons); add plausible per-reason
      bounds like the existing `draftReroll`/`continueRun` gates.
- [ ] Migration: `PurchasesAndEntitlements`.

### Client (`features/store/`)

- [ ] Add `in_app_purchase`.
- [ ] New feature folder following the house pattern (domain → data → presentation).
- [ ] Flow: buy → Play token → `POST /purchases/verify` → server grants →
      refresh entitlements → write local Drift `entitlements` table (**DB schema v5**) →
      `completePurchase` (consume for coin packs, acknowledge for the rest).
- [ ] **Pending-purchase recovery**: `purchaseStream` listener at app start re-verifies
      anything Play still considers unacknowledged. This is what saves you when a user
      pays and the app dies mid-flight.
- [ ] Settings → **Restore purchases**.
- [ ] `EntitlementRepository` exposed on `SessionDependencies`, read by the ad gate and
      the store UI.
- [ ] **Legal:** real-money IAP goes live → `refund.md` §3 and `terms.md` §4 shift from
      "may, now or in the future" to present tense; bump `LegalDocuments.version` → **4**.

---

## 🔨 Phase 3 — Deepen the sink (3A SHIPPED 2026-08-04, 3B next)

### ✅ 3A — catalog depth (shipped)

Permanent sink **7,800 → ~24,000**. Analyze clean, 207/207 tests pass.

- [x] **Outfitter 13 → 25 items**, each slot gaining three mid-tier looks and a
      **legendary** (Eclipse 2,200 / Revenant 2,800 / Gold Rush 3,200). Still
      strictly visual — the `GameBalance`/`BulletStats` guardrail is untouched.
- [x] **Gunsmith prestige, honestly.** Only Iron Resolve, Keen Eye and
      Gunfighter's Memory took a third level. **Reinforced Heart, Quick Hands and
      Lucky Strike were deliberately NOT raised** — they map onto upgrade cards
      whose `maxStacks` already caps them, so the extra level would have taken
      coins and done nothing. A test now encodes that invariant so nobody
      "deepens the sink" by selling no-ops later.
- [x] **The continue is now a ladder, not a one-shot** — 500 / 1,200 / 2,500,
      capped at three. The first is a forgiving second chance, the third costs
      most of a bankroll, so a deep run can't be bought outright and the
      leaderboard keeps meaning something. This is the first genuinely
      REPEATABLE sink, which is what coin packs need.
- [x] Backend catalogs moved in lockstep — `CosmeticDefinitions` (unknown ids are
      dropped, which would silently un-own a purchase) and `MetaPerkDefinitions`
      (levels are clamped, so a client raised alone loses the paid level on sync).
- [x] Prices verified against the backend's coin sanity ceilings by test.

### ✅ 3B — pre-run consumables (SHIPPED 2026-08-04)

Everything above is still ONE-TIME spending. A player who owns it all has
nothing to buy again, so coin packs still don't have durable demand.

- [x] **Four consumables** — Field Dressing (+1 heart), Loaded Deck (free rare),
      Prospector's Charm (×2 coins), Second Opinion (free reroll). 200–400 coins
      each, deliberately cheap: a small frequent decision, not a milestone.
- [x] **Spent at RUN START, not run end** — tying it to the end would let a
      player quit out after a bad opening and keep the item.
- [x] **The sheet is skipped when stock is empty**, so the one-tap path from
      Home to playing is untouched for anyone who hasn't bought in.
- [x] **Max 2 per run.** Taking everything every time isn't a decision, and a
      run starting with every advantage stops resembling the run everyone
      else's leaderboard score came from.
- [x] Drift schema v8 + `consumableState` sync (last-writer-wins). The server
      processor is explicitly written to allow the aggregate going DOWN —
      unlike perks and cosmetics, stock is spent, so a smaller value is not
      evidence of tampering.
- [x] Backend: `PlayerConsumable`, `ConsumableDefinitions`,
      `ConsumableStateProcessor`, snapshot restore, migration applied.
- [x] **Normal runs only** — daily challenges and tournaments stay identical
      worldwide, enforced at the single construction site.
- [x] Verified against a running backend: valid stock applies and reaches the
      snapshot, unknown ids sanitize away with a server warning, stale replays
      are no-ops, zero counts round-trip as "not held".
### ✅ 3C — earn-rate retune + high-stakes bracket (SHIPPED 2026-08-04)

- [x] **Earn rates raised to match the sink.** 3A/3B tripled the permanent sink
      and added a repeatable one but left income alone: a wave-10 run earned
      ~486, so buying one consumable per run netted ~186 and "own everything"
      sat at ~129 runs — making the consumable a punishment rather than a
      choice. Now `coinPerKill` 3→4, `dropValue` 4→5, `waveClearBonus` 15→22:
      ~670 a run, ~370 net after a consumable, ~64 runs to own everything
      (36 if ignoring them). `chainBonusPerKill` 4→6 rises proportionally MORE,
      so income leans toward playing WELL rather than merely long.
      **Derived from sink arithmetic, not play-tested for feel** — all four are
      panel-tunable; promote whatever actually feels right.
- [x] **High-stakes tournament bracket.** Every cadence now generates BOTH a
      Standard and a HighStakes tournament per window (~10× fee and pool), so a
      player picks their level rather than being handed one fee. Both share the
      window seed and therefore the same RULESET — a bigger buy-in buys risk and
      reward, never an easier draw. The fee and pool use the SAME multiplier:
      raising the fee faster would make it a tax, raising the pool faster would
      make skipping the standard board strictly correct. Values stay under the
      `CoinTxnProcessor` ceilings (entry 50k, reward 1M).

**Still open — needs a human, not me:**

- [x] ~~Play-test the loadout sheet~~ — pre-empted instead. The selection is
      remembered (per-account, filtered to what's still in stock) so the sheet
      opens pre-ticked, and **RIDE AGAIN carries the same kit**, so a retry
      never returns to Home. Combined with the skip-when-empty rule, an engaged
      player's loop is: tap orb → tap RIDE OUT. Still worth a look on device,
      but the tax it was meant to catch is gone.
- [ ] **Play-test the retuned earn rates.** The arithmetic says ~64 runs; only
      playing says whether that *feels* like progress or a grind.

### Original scope (reference)</

**Do this before coin packs exist.** Today's 7,800-coin ceiling is the reason a coin
pack would not sell. Target: **~40,000 lifetime sink plus a genuinely repeatable floor.**

- [ ] **Outfitter: 12 → ~30 items**, with a legendary tier at 1,500–4,000. Still
      strictly visual — the `GameBalance`/`BulletStats` guardrail is absolute.
- [ ] **Gunsmith prestige levels** — raise `maxLevel` on the cheap perks and add a
      second tier band. Survivability/utility/economy only; **never flat bullet damage.**
- [ ] **Pre-run consumables** — the load-bearing addition. One-run boosters chosen on the
      pre-run screen (extra heart, starting rare card, coin doubler, extra reroll charge).
      Consumed on use → **the first truly repeatable coin sink**, and the thing that makes
      a coin pack make sense. Normal runs only; **never** in daily challenges or
      tournaments (fairness rule stands).
- [ ] **Continue beyond once per run** at a steeply escalating cost (500 → 1,200 → 2,500),
      still capped. Update the `continueRun` bound in `CoinTxnProcessor` to match.
- [ ] Raise tournament entry fees for a new high-stakes bracket with a bigger pool.
- [ ] Re-tune `GameBalance.I.economy` earn rates against the new sink depth (panel-tune
      first, then promote the felt numbers to defaults, per the working agreement).
- [ ] Backend catalogs (`CosmeticDefinitions`, `MetaPerkDefinitions`) move in **lockstep**.

---

## ✅ Phase 4 — Ads (SHIPPED 2026-08-04)

Analyze clean, 242 tests pass (10 new on the pacing gate), debug APK builds.

- [x] `google_mobile_ads` 9.0.0, AdMob app id in the manifest (hardcoded — the
      SDK reads it at process start and the app crashes without it).
- [x] **UMP consent gate.** Nothing loads until it reports back. Fails open on
      SDK errors, never claims consent it didn't get.
- [x] **`AdConfig`: debug builds always use Google's test units**, whatever
      `.env` says.
- [x] **`InterstitialGate`** — pure logic, no SDK, all rules unit-tested. ≥4
      runs AND ≥3 min, ≥5 lifetime runs, normal runs only, not session-ending,
      suppressed 24h after any rewarded watch. ≈1 per 15–20 min.
- [x] **Rewarded continue-on-death** — WATCH AD above PAY COINS (free first;
      burying it reads as pushing the paid option), offered only when an ad is
      genuinely loaded, on a cubit path that can never touch coins.
- [x] **Interstitial** on the results screen only — never mid-run, never on the
      death beat, guarded against a re-emitted state showing two for one run.
- [x] **Banner** on Leaderboards / Awards / Statistics / Trick-Shot only.
      Opt-in per screen, so it can't land on the Gunsmith, Outfitter or store —
      asking someone to look at an ad where they're about to spend money.
      Renders nothing until an ad loads.
- [x] **`no_ads` gate**, watched live so a purchase takes effect without a
      restart; reset on sign-out. Rewarded ads stay for everyone.
- [x] **Settings → Ad privacy** reopens the consent form (EEA/UK/CH only).
- [x] **Legal v4** — the "we do not show ads" promise deleted, Advertising
      section added naming the advertising identifier and the three real player
      choices. Hosted copies re-synced.

### ✅ Server-side verification (SHIPPED 2026-08-04)

The gap below is now closed. `GET /api/v1/ads/ssv` verifies Google's ECDSA
signature over the raw query string (DER-encoded, not raw r||s — the easy thing
to get silently wrong), dedupes on AdMob's `transaction_id` as the primary key,
and credits from `AdRewardDefinitions` rather than the callback's own
`reward_amount`. The client attaches its backend user id to each rewarded ad and
pulls credited payouts via `/ads/rewards/pending` + `/acknowledge`, mirroring
them locally exactly like IAP coins.

**Remaining: set the callback URL and reward items on the four rewarded ad
units** — see `ADMOB_SETUP.md` §5 — and deploy the backend.

<details><summary>Original note on why it was deferred</summary>

### ⬜ Deliberately NOT shipped: coin-granting rewarded ads

`db_reward` placements for **double-coins** and **daily-bonus** are built but
NOT wired, and this is a considered omission rather than an oversight.

`CoinTxnProcessor` rejects `adReward` from the client — that trust boundary went
in during Phase 2 precisely so purchased and ad-granted currency can't be
minted. Granting these client-side would either reopen that hole or credit
coins that never reach the server, silently diverging the balance and vanishing
on reinstall.

They need **AdMob server-side verification**: a backend endpoint Google calls
directly, verifying the signed callback against Google's public keys, then
crediting server-side exactly like a verified purchase. That's a real piece of
backend work and belongs with Phase 5, alongside the SSV callback URLs in
`ADMOB_SETUP.md` §5.

**The two shipped placements (continue, reroll) grant no coins**, so they work
correctly today.

</details>

### Console work still required

- [ ] AdMob → Privacy & messaging: publish the GDPR and US-states messages.
      **Until the GDPR message exists, EEA/UK users see no ads at all** —
      the consent gate correctly refuses to request them.
- [ ] AdMob → App content: "not directed to children" (must match `privacy.md` §5).
- [ ] Play Console → Data safety: declare advertising data + the ads declaration.
- [ ] `app-ads.txt` on pranta.dev.

---

## Phase 4 — original scope (reference)

Posture, as decided: **rewarded ads carry the load, one minimal banner, interstitials
genuinely rare.**

- [ ] Add `google_mobile_ads`.
- [ ] **UMP / GDPR consent form before any ad loads.** Non-optional; ship it first.
- [ ] `core/ads/ad_service.dart` behind a seam (same pattern as analytics/audio) so
      tests fake it and a fill failure degrades silently to "no ad".

### Rewarded (opt-in — the UI already exists)

- [ ] **`ContinueOverlay`** — "WATCH AD" beside "PAY 500". Highest-intent moment in the
      whole game: the player just died and wants back in.
- [ ] **Draft reroll** — first reroll of a run free via ad; coins after that.
- [ ] **Results screen** — "DOUBLE YOUR RUN COINS".
- [ ] **Daily bonus** — one ad/day for a coin top-up, next to the login streak claim.
- [ ] **AdMob server-side verification (SSV)** → a backend callback grants `adReward`
      coins **server-side**. Same rule as IAP: the client never mints these itself.

### Banner (minimal)

- [ ] **Only** on Leaderboards, Awards, Statistics, and the Trick-Shot gallery — static
      list screens that already scroll.
- [ ] **Never** on Home (`CLAUDE.md` requires it stay no-scroll / no-overflow — a banner
      breaks that contract), **never** in-run, **never** on the results screen, **never**
      over the `AnimatedArenaBackground` hero moments.

### Interstitial (rare, by explicit design)

Gate must satisfy **all** of:
- [ ] ≥ 4 runs since the last interstitial, **and** ≥ 3 minutes elapsed;
- [ ] lifetime `runsPlayed` ≥ 5 (never during onboarding);
- [ ] never on the run that ends a session, never on a first-3-waves death;
- [ ] fully suppressed for 24h after any rewarded ad watch (don't tax paying attention);
- [ ] never during a tournament or daily-challenge run.

Net effect ≈ one interstitial per 15–20 minutes of engaged play.

### Entitlement interaction

- [ ] `no_ads` kills banner + interstitial. **Rewarded stays available** — that's the
      genre standard and players expect to keep the opt-in bonus.

### Legal (the big one)

- [ ] Rewrite `privacy.md` — **delete line 86's "we do not show ads" promise**, add AdMob
      to §4 third-party services, describe advertising identifiers and the consent choice.
- [ ] `AD_ID` permission in the Android manifest.
- [ ] Play **Data Safety** form update + the ads declaration in the Console.
- [ ] Bump `LegalDocuments.version` → **5**, update all three `**Version N**` lines,
      re-copy all three files to `G:\MyProjects\privacy-project\Projects\deadbounce\`.
- [ ] Confirm the target-audience/content rating still holds with ads enabled.

---

## Phase 5 — The products (ship one at a time)

Price in Play's **local currency tiers** — set the anchor in the Console and let Play
localize; do not hard-code USD in the client. Prices below are anchors, not gospel.

- [ ] **5A — Remove Ads / Supporter Pack** (~$2.99 one-time). Grants `no_ads` +
      a supporter-exclusive cosmetic + a one-time coin grant. Historically the
      best-converting IAP in this genre, and the only one that needs Phase 4 to exist.
- [ ] **5B — Premium cosmetic packs** (~$1.99–$4.99). Direct purchase, bypasses coins
      entirely. Highest margin, **zero balance risk** because cosmetics provably cannot
      touch `GameBalance`. Ship 2–3 themed bundles.
- [ ] **5C — Coin packs** (4 tiers, ~$0.99 → ~$19.99, escalating bonus %). Only
      meaningful **after Phase 3** — without the deeper sink there is nothing to spend on.
- [ ] **5D — Seasonal "Bounty Pass"** (~$4.99/season). Free + premium track over a
      ~4-week season. Your tournament and daily-challenge cadences are already the
      season skeleton. Needs backend `Season` + `SeasonProgress` entities and a Hangfire
      rollover job alongside the existing tournament generators. Highest ARPU, biggest
      build — **last on purpose**.

---

## Guardrails (do not violate, ever)

1. **Nothing purchasable adds flat bullet damage.** It would break "no damage till it
   bounces" — the entire identity of the game.
2. **Cosmetics never touch `GameBalance`/`BulletStats`.** Pure render layer.
3. **Daily challenges and tournaments stay perk-free, consumable-free, and identical
   worldwide.** Competitive integrity is the reason the leaderboards mean anything.
4. **No purchased advantage on a leaderboard board.** Coins may buy convenience and
   cosmetics in normal runs; they must never buy rank.
5. **IAP and ad-reward coins are credited by the SERVER only.** Client-minted premium
   currency devalues every pack you sell.
6. **Every phase that changes data collection, purchases, or virtual goods** →
   re-check `assets/legal/*.md`, bump `LegalDocuments.version`, re-copy to the hosted
   repo (`CLAUDE.md` rule).
7. **Backend catalogs move in lockstep with client catalogs.** Never let them drift.

---

## Working agreement

- One phase at a time; play-test between phases.
- `flutter analyze` clean + `flutter test` green + `dotnet build` 0 errors before
  anything ships.
- Tuning lives in `GameBalance` (debug panel) so numbers can be *felt* before being
  promoted to defaults.
- Phases 0 and 1 have **no revenue** and are still the highest-value work in this
  document. Do not skip ahead to Phase 5.
