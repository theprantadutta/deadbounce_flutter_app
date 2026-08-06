# Play Billing — go-live checklist

> **Status: the code is finished on both sides.** Products and subscriptions are
> fully wired in Flutter and .NET; the only thing missing is the Play Console
> configuration, which **cannot be done until the app is in production** (Play
> won't let you create in-app products for an app that has never been published
> to a release track).
>
> Until then the store shows *"The shop is not open yet, partner."* — that is the
> expected, correct behaviour, not a bug. Nothing else in the app is affected.

---

## Why it errors until then, and why that's fine

`queryProductDetails` asks Play about our SKUs. Play doesn't know them yet, so
every SKU comes back in `notFoundIDs`, every offer is `available: false`, and
`StoreCubit` shows the "not open yet" message instead of a shelf of dead rows.

The **server** side is already live and safe: `/purchases/verify` exists, and if
it somehow received a token it would ask Google, get a 404, and reject it. There
is no state to clean up later.

---

## 1. Get the app into production first

At least one release must have rolled out to a Play track. Internal testing
counts for *creating* products, but licence-tester purchases still need the app
published to a track with the same `applicationId` (`com.pranta.deadbounce`) and
version code.

## 2. Service account permissions *(done — 2026-08-04)*

Play Console → **Users and permissions** → the service account behind
`google-play-service-account.json` needs:

- **View financial data, orders, and cancellation survey responses** — required
  or every `purchases.products.get` / `purchases.subscriptionsv2.get` returns 401.
- **View app information** (read-only) is enough for everything else.

Also make sure the account is linked under **Setup → API access**.

## 3. Create the one-time products

Play Console → **Monetize → Products → In-app products → Create product.**

The **product ID must match exactly** — it's the join key between the Play
Console, `ProductDefinitions.cs` (server) and `store_catalog.dart` (client). A
typo means the player pays and verification rejects the SKU as unknown.

| Product ID | Type | What the SERVER grants (authoritative) | Suggested price tier |
|---|---|---|---|
| `db_remove_ads` | One-time | `no_ads` entitlement | ~$2.99 |
| `db_supporter_pack` | One-time | `supporter` entitlement + 2,000 coins + `trail_supporter` | ~$4.99 |
| `db_coins_small` | One-time (consumable) | 1,000 coins | ~$0.99 |
| `db_coins_medium` | One-time (consumable) | 5,500 coins | ~$4.99 |
| `db_coins_large` | One-time (consumable) | 12,000 coins | ~$9.99 |
| `db_coins_huge` | One-time (consumable) | 30,000 coins | ~$19.99 |

**Prices are yours to set in the Console** — set the anchor and let Play localise.
The app never hardcodes a price; it renders `ProductDetails.price` exactly as Play
returns it, already in the player's currency.

> Google Play has no "consumable" checkbox — consumability is a client decision.
> The four coin packs are declared `StoreProductKind.consumable` in
> `store_catalog.dart`, which routes them through `buyConsumable`; everything else
> is acknowledged and owned forever. **If you add a coin pack, set its kind in
> BOTH catalogs** or it can only ever be bought once.

## 4. Create the subscription

Play Console → **Monetize → Subscriptions → Create subscription.**

| Subscription ID | Base plan | Server grants |
|---|---|---|
| `db_bounty_pass` | Monthly, auto-renewing | `bounty_pass` entitlement (28-day fallback window) |

- Base plan ID can be anything (`monthly` is fine) — the app only ever references
  the **subscription ID**.
- Set the base plan to **auto-renewing**, and activate it (a subscription with no
  active base plan is invisible to `queryProductDetails`).
- Grace period / account hold: leave Play's defaults on. The backend's
  `SubscriptionRefreshJobService` deliberately treats grace-period and on-hold as
  still-entitled, because Google is retrying the payment and pulling a paid
  feature mid-retry earns a refund plus a one-star review.

## 5. Licence testers

Play Console → **Setup → Licence testing** → add your Google account.

Licence testers get the real purchase flow with real Play UI and **no charge**,
including renewals on an accelerated clock (a monthly subscription renews every
~5 minutes), which is the only practical way to test the renewal job.

## 6. Verify end to end

1. Install a build signed with the **upload key** (not a debug APK) from a Play
   track your test account can reach.
2. Open Settings → **Supply run**. The shelf should show real prices.
3. Buy `db_coins_small`. Expect: Play sheet → coins appear → the API logs
   `Purchase granted: db_coins_small`.
4. Kill the app mid-purchase and reopen it — the purchase should be recovered and
   granted on next launch (that's `storeRepository.start()` replaying it).
5. Buy `db_bounty_pass`; check the tile reads *"Active until …"* with a MANAGE
   button, and that `player_entitlements` has a row with a non-null `expires_at`.
6. Settings → **Restore purchases** on a fresh install of the same account —
   everything non-consumable should come back.

---

## What is already handled in code (don't re-solve these)

- **Server-authoritative grants.** The client sends only
  `{product_id, purchase_token}`. Price, coin amount and entitlement all come
  from `ProductDefinitions.cs` after Google confirms the token.
- **Replay-safe.** `PurchaseReceipt`'s primary key IS the Play purchase token, so
  a re-verify can never grant twice. The client separately guards its local coin
  mirror with `processed_purchases`.
- **Network-safe.** A purchase whose verification fails is deliberately NOT
  completed, so Play redelivers it until the server confirms. The player's money
  is never lost to a bad connection.
- **Renewals and revocations.** `deadbounce-subscription-refresh` (hourly, :25)
  re-asks Google about entitlements near expiry, extends renewals, and revokes
  cancelled/refunded ones after their paid period ends.
- **Guests can't buy.** A guest account dies with the install, so the store sends
  them to link first (Profile → LINK AN ACCOUNT).
- **Restore** lives in Settings, in the store, and in the `/sync/snapshot` pull.

## Still deliberately not done

- **Legal docs are not yet in present tense.** `terms.md` / `refund.md` describe
  purchases as "may, now or in the future". Flip them — and bump
  `LegalDocuments.version` — when products go live. **Batch that with the Phase 4
  ads rewrite** so users aren't re-prompted for consent twice in a fortnight.
- **No products are surfaced on Home.** The store is reachable from Settings only.
  That's intentional until there's something to sell.
