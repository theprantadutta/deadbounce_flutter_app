# AdMob Setup — what to create, and where the IDs go

> **For: Pranta.** Fill in the tables below in the AdMob console while I work on
> the earlier phases. Nothing here changes any code — when you're done, the IDs
> get pasted into `.env` and Phase 4 picks them up.
>
> **You do not need to do this urgently.** Ads are **Phase 4** in
> `MONETIZATION_PLAN.md`; Phases 1–3 land first. This doc exists so the console
> work can happen in parallel instead of blocking the build later.

---

## 0. Before you start

- **App package name:** `com.pranta.deadbounce` (must match exactly).
- **Platform:** Android only for now. iOS rows are included but can stay empty
  until an iOS build is on the table.
- Use the **same Google account** that owns the Play Console listing — AdMob
  will offer to link the app to Play, and you want that link (it enables
  Play-sourced app metadata and better fill).

---

## 1. Create the AdMob app

AdMob console → **Apps → Add app** → Android → "Yes, it's listed on a supported
store" → search `Deadbounce` → link it.

If the Play listing isn't discoverable yet, choose "No" and create it manually
with the name `Deadbounce`, then link it later under **App settings**.

**Copy the App ID** (format `ca-app-pub-0000000000000000~0000000000` — note the
**tilde `~`**, not a slash):

| Field | Value |
|---|---|
| AdMob **App ID** (Android) | `ca-app-pub-9242904787767394~7497802908` |
| AdMob **App ID** (iOS, optional) | *(leave blank for now)* |

> ⚠️ The App ID is the one value that also has to go in
> `android/app/src/main/AndroidManifest.xml` as a `<meta-data>` tag — the app
> **crashes on launch** without it once the SDK is added. I'll wire that from
> the `.env` value; you just need to supply it.

---

## 2. Create the ad units

**Apps → Deadbounce → Ad units → Add ad unit.** Create **six**. Naming matters
only for your own reporting, but keep it consistent — these names are what you'll
be reading in revenue reports at 2am, and `Rewarded 1` tells you nothing.

Ad unit IDs use a **slash `/`**: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`.

### Rewarded (4) — these carry the revenue

Opt-in only. Every one of these sits on UI that **already exists** in the game.

| # | Ad unit name to type | Format | Reward amount | Reward item | Where it appears |
|---|---|---|---|---|---|
| 1 | `DB Rewarded — Continue` | Rewarded | `1` | `continue` | The death screen (`ContinueOverlay`). "WATCH AD" next to "PAY 500 COINS". Highest-intent moment in the game. |
| 2 | `DB Rewarded — Reroll` | Rewarded | `1` | `reroll` | The upgrade draft. First reroll of a run free via ad. |
| 3 | `DB Rewarded — Double Coins` | Rewarded | `1` | `double_coins` | Results screen. "DOUBLE YOUR RUN COINS". |
| 4 | `DB Rewarded — Daily Bonus` | Rewarded | `1` | `daily_bonus` | Next to the login-streak claim. One per day. |

> The reward **amount/item** fields are just labels AdMob echoes back to the app —
> the real coin values stay server-side (see §5). Set amount `1` and use the item
> strings above so the callback is unambiguous.

### Banner (1) — deliberately restricted

| # | Ad unit name to type | Format | Where it appears |
|---|---|---|---|
| 5 | `DB Banner — Meta Screens` | Banner | **Only** Leaderboards, Awards, Statistics, Trick-Shot gallery. Never on Home, never in-run, never on the results screen. |

When creating it, pick **Anchored adaptive banner** if offered — it sizes to the
device instead of the legacy fixed 320×50.

### Interstitial (1) — genuinely rare

| # | Ad unit name to type | Format | Where it appears |
|---|---|---|---|
| 6 | `DB Interstitial — Between Runs` | Interstitial | Between runs, behind a hard gate: ≥4 runs **and** ≥3 min since the last one, never in the first 5 lifetime runs, never on a session-ending run, never in a tournament/daily run, and fully suppressed for 24h after any rewarded watch. Works out to roughly one per 15–20 min. |

---

## 3. Fill this in — I read exactly these keys

Paste into **`.env`** (and add the same keys with placeholder values to
`.env.example`, which is committed). Leave a key blank and that placement is
simply disabled — the app runs fine without it.

```dotenv
# ---- AdMob (Phase 4) ----
# App ID uses a TILDE. Ad unit IDs use a SLASH.
ADMOB_APP_ID_ANDROID=ca-app-pub-9242904787767394~7497802908

ADMOB_REWARDED_CONTINUE=ca-app-pub-9242904787767394/9035080005
ADMOB_REWARDED_REROLL=ca-app-pub-9242904787767394/7147283266
ADMOB_REWARDED_DOUBLE_COINS=ca-app-pub-9242904787767394/1053216427
ADMOB_REWARDED_DAILY_BONUS=ca-app-pub-9242904787767394/2262356315

ADMOB_BANNER_META=ca-app-pub-9242904787767394/5039994671
ADMOB_INTERSTITIAL_BETWEEN_RUNS=ca-app-pub-9242904787767394/6348226976

# Comma-separated AdMob test device IDs (see §6). Debug builds always use
# Google's official test ad units regardless, so this is only for verifying
# LIVE unit ids on a real device without risking an invalid-traffic strike.
ADMOB_TEST_DEVICE_IDS=
```

**Debug builds ignore all of the above** and use Google's official test ad unit
IDs — same rule as `LoggingAnalyticsService`: development traffic must never
touch production. Clicking your own live ads is the fastest way to get an AdMob
account suspended, and there is no appeal worth the trouble.

---

## 4. Privacy & messaging (this one is legally load-bearing)

AdMob → **Privacy & messaging**. Two messages to create:

1. **GDPR (EEA + UK)** — required. This is the UMP consent form the app shows
   before it loads a single ad. Turn it on, select the ad partners (accept the
   default full list unless you have a reason not to), and publish.
2. **US states (CCPA/CPRA)** — turn on; it's a "Do Not Sell" link, low effort.

Also set:
- **App content → this app is not directed to children** (matches
  `privacy.md` §5, which says the app isn't directed at under-13s). Getting this
  wrong is a Families-policy violation, so keep the two consistent.
- **EU consent → "Ask for consent"**, not "Do not ask".

> The app will **not** load ads until UMP reports consent obtained-or-not-required.
> That's the correct behaviour and it's how Phase 4 is built.

---

## 5. Rewarded SSV (do this one WITH me, not before)

**Ad units → [rewarded unit] → Server-side verification.** Each of the four
rewarded units needs a callback URL pointing at the Deadbounce backend.

Leave this blank for now — the endpoint doesn't exist yet. It arrives with Phase
2/4, and the URL will look like:

```
https://<your-api-host>/api/v1/ads/ssv
```

**Why it matters:** without SSV, a modified client can claim "I watched the ad,
give me the coins" without watching anything. With it, Google calls the backend
directly and the backend credits the coins — the same server-authoritative rule
that already governs achievement rewards and tournament payouts. Ad-granted coins
must never be minted client-side.

---

## 6. Getting your test device ID

Run a debug build, then check logcat for a line like:

```
Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("33BE2250B43518CCDA7DE426D04EE231"))
```

Copy that hex string into `ADMOB_TEST_DEVICE_IDS`. This lets you exercise the
**live** ad unit IDs on your own device without generating invalid traffic.

---

## 7. app-ads.txt

Publish an `app-ads.txt` at the root of the developer domain listed on your Play
listing (`https://pranta.dev/app-ads.txt`). AdMob shows you the exact line under
**Apps → app-ads.txt**; it looks like:

```
google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0
```

Not strictly required to serve ads, but without it a chunk of programmatic demand
won't bid, and you leave real money on the table. It takes five minutes.

---

## 8. Checklist

- [ ] AdMob app created and linked to the Play listing
- [ ] App ID copied into `.env` as `ADMOB_APP_ID_ANDROID`
- [ ] 4 rewarded units created (Continue, Reroll, Double Coins, Daily Bonus)
- [ ] 1 banner unit created (Meta Screens)
- [ ] 1 interstitial unit created (Between Runs)
- [ ] All 6 unit IDs pasted into `.env`
- [ ] GDPR + US-states privacy messages published
- [ ] "Not directed to children" set, EU consent = "Ask for consent"
- [ ] `app-ads.txt` published at `pranta.dev`
- [ ] Test device ID captured
- [ ] *(with me, later)* SSV callback URLs set on all 4 rewarded units

---

## What I still have to do on my side (Phase 4)

Listed so it's clear this file isn't the whole job:

- Add `google_mobile_ads`, the manifest `<meta-data>` App ID, and the UMP
  consent flow.
- `core/ads/ad_service.dart` behind a seam (same pattern as analytics/audio), so
  tests fake it and a fill failure degrades silently to "no ad".
- The four rewarded placements, the restricted banner, the hard-gated
  interstitial.
- The `no_ads` entitlement check that kills banner + interstitial (rewarded stays
  — that's genre standard and players expect to keep the opt-in bonus).
- **Legal:** delete the "we do not show ads" promise at `privacy.md:98`, add
  AdMob to §4, bump `LegalDocuments.version`, re-copy to
  `G:\Personal\MyProjects\privacy-project\Projects\deadbounce\`, update Play
  Data Safety. If ads and IAP land close together I'll batch both into **one**
  version bump so users aren't re-prompted for consent twice.
