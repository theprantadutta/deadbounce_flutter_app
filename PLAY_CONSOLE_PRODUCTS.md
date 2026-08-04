# Play Console — Products & Subscriptions to create

> **For: Pranta.** Create these by hand in the Play Console. Everything here is
> already wired in code (Phase 2), so once these exist the store works end to end.
>
> **⚠️ The Product IDs below must match EXACTLY.** They are the contract between
> three places: the Play Console, `ProductDefinitions.cs` (backend) and
> `store_catalog.dart` (client). A typo means the player pays, `POST /purchases/verify`
> rejects the SKU as unknown, and they get nothing.
>
> **Product IDs are permanent.** Play will not let you rename or reuse one after
> creation. Get them right the first time.

---

## 0. Do these two things FIRST

Neither is optional — the store cannot work without them.

### a) Enable the Play Developer API *(done 2026-08-04)*

Google Cloud Console → APIs & Services → enable **Google Play Android Developer
API** for project `deadbounce-421b4`. ✅ Confirmed working.

### b) Invite the service account to the Play Console *(STILL OUTSTANDING)*

This is a **separate system** from Google Cloud, and that trips almost everyone:
enabling the API lets the service account *call* Google, but it still has no
access to *your developer account*. Verification currently fails with
`401 permissionDenied` for exactly this reason.

**Play Console → Users and permissions → Invite new users**, and add:

```
deadbounce-play-verify@deadbounce-421b4.iam.gserviceaccount.com
```

Then grant it:
- **Account permissions → "View financial data, orders, and cancellation survey
  responses"**
- **App permissions → Deadbounce** (at minimum view access)

Changes usually apply within minutes, but Google allows itself up to 24 hours.

> The server logs a loud, explicit `MISCONFIGURED` error naming these exact
> steps whenever Google answers 401/403, so this failure never has to be
> guessed at again. Purchases are **not** lost while it is broken — they stay
> uncompleted and Play redelivers them once verification works.

### c) Upload a build containing the Billing library

Play only shows products to an app whose **uploaded build** contains Play Billing.
Upload the current build to **internal testing** at least once before testing
purchases — a local `flutter run` alone won't see them.

---

## 1. In-app products (Monetize → Products → In-app products)

Six of these. Play calls them all **"managed products"** — there is **no
consumable checkbox in the Console**. Whether something is consumable is decided by
the app (we call `buyConsumable` + consume for coin packs, `buyNonConsumable` for
the rest). So just create all six the same way; the "Type" column below is what the
CODE does, for your reference.

Character limits: **Name ≤ 55**, **Description ≤ 200**.

### 1.1 `db_remove_ads`

| Field | Value |
|---|---|
| **Product ID** | `db_remove_ads` |
| **Name** | `Remove Ads` |
| **Description** | `Removes banner and interstitial ads for good. Rewarded ads stay available — those are always your choice, and they keep paying out.` |
| **Price (anchor)** | **US $2.99** / **₹249** |
| Type (code) | Non-consumable |
| **Grants** | Entitlement `no_ads` |

### 1.2 `db_supporter_pack`

| Field | Value |
|---|---|
| **Product ID** | `db_supporter_pack` |
| **Name** | `Supporter Pack` |
| **Description** | `Removes ads, hands over 2,000 coins, and unlocks the supporter-only Gunsmith's Gratitude bullet trail. The best value in the shop.` |
| **Price (anchor)** | **US $4.99** / **₹399** |
| Type (code) | Non-consumable |
| **Grants** | Entitlement `supporter` (which implies `no_ads`), 2,000 coins, cosmetic `trail_supporter` |

> Price it clearly above Remove Ads. It has to read as the obvious upgrade, or it
> cannibalises the cheaper product instead of lifting the average.

### 1.3–1.6 Coin packs

All four are consumable in code, so they can be bought repeatedly.

| Product ID | Name | Description | Price anchor (USD / INR) | Coins |
|---|---|---|---|---|
| `db_coins_small` | `Pocket Change` | `1,000 coins for the Gunsmith and the Outfitter. Every coin can still be earned by playing — this just saves you the ride.` | $0.99 / ₹89 | 1,000 |
| `db_coins_medium` | `Saddle Bag` | `5,500 coins — 10% more per coin than Pocket Change. Spend them on perks, looks, rerolls and buy-backs.` | $4.99 / ₹399 | 5,500 |
| `db_coins_large` | `Strongbox` | `12,000 coins — 20% more per coin. Enough to kit out the Gunsmith properly.` | $9.99 / ₹799 | 12,000 |
| `db_coins_huge` | `The Vault` | `30,000 coins — 50% more per coin, the best rate in the game. For the long haul.` | $19.99 / ₹1,599 | 30,000 |

**The bonus percentages in the copy are load-bearing** — they're what makes the
ladder worth climbing. If you change a price, recheck that coins-per-currency still
improves at every tier, and update `ProductDefinitions.cs`, `store_catalog.dart`
and these descriptions together.

---

## 2. Subscription (Monetize → Products → Subscriptions)

One, for Phase 5D. **You can safely skip this until the Bounty Pass is actually
built** — the code path exists and is verified, but there's no season content yet.

### 2.1 `db_bounty_pass`

| Field | Value |
|---|---|
| **Product ID** | `db_bounty_pass` |
| **Name** | `Bounty Pass` |
| **Description** | `Unlocks the premium reward track for the current season. Earn exclusive trails, skins and coin payouts as you play. Renews every 4 weeks; cancel any time.` |
| **Grants** | Entitlement `bounty_pass` |

Then add a **base plan** (Play requires at least one):

| Field | Value |
|---|---|
| **Base plan ID** | `bounty-pass-4weekly` |
| **Type** | Auto-renewing |
| **Billing period** | **Every 4 weeks** |
| **Price (anchor)** | **US $4.99** / **₹399** |
| Grace period | 7 days (recommended) |
| Account hold | On (Play default) |

> **Use "every 4 weeks", not "monthly".** The backend's catalog fallback is
> `SubscriptionDays: 28`. Play's own expiry always wins when it sends one, but
> keeping the two aligned means the fallback can't quietly grant a few extra days.
>
> The **grace period matters**: the verifier deliberately treats
> `IN_GRACE_PERIOD` and `ON_HOLD` as still-active, because Google is retrying the
> payment. Yanking a paid feature mid-retry earns a refund and a one-star review.

---

## 3. Pricing notes

- Set the price **once in your home currency**; Play auto-converts to every other
  market. Do **not** hardcode prices anywhere — the app reads
  `ProductDetails.price` from Play at runtime, already localised.
- The USD/INR pairs above are **anchors, not conversions**. Play's own India
  pricing tends to sit well below a straight FX conversion, which is correct —
  price to the market, not to the dollar.
- You can change prices later. You **cannot** change a Product ID.

---

## 4. Testing without paying

**Play Console → Setup → License testing** → add your Google account(s).

License testers get the real purchase flow — real Play sheet, real tokens, real
server verification — but are **never charged**, and test purchases auto-refund.
This is the only sane way to test the flow end to end.

Test at minimum:
1. Buy `db_coins_small` → coins land, balance updates.
2. Buy it **again** → works (proves consumption; if it fails, the consume step is broken).
3. Buy `db_remove_ads` → shows OWNED, and stays OWNED after an app restart.
4. **Kill the app mid-purchase**, reopen → the purchase completes on its own
   (this is the pending-purchase recovery path, the one that saves real money).
5. **Reinstall** → Settings → Restore purchases → Remove Ads comes back.
6. **Airplane mode mid-purchase** → the purchase is not lost; it verifies once
   you're back online.

---

## 5. What the app does with each product

For cross-checking against `ProductDefinitions.cs` — this table is the whole
contract:

| Product ID | Kind | Coins | Entitlement | Cosmetics |
|---|---|---|---|---|
| `db_remove_ads` | Non-consumable | — | `no_ads` | — |
| `db_supporter_pack` | Non-consumable | 2,000 | `supporter` → implies `no_ads` | `trail_supporter` |
| `db_coins_small` | Consumable | 1,000 | — | — |
| `db_coins_medium` | Consumable | 5,500 | — | — |
| `db_coins_large` | Consumable | 12,000 | — | — |
| `db_coins_huge` | Consumable | 30,000 | — | — |
| `db_bounty_pass` | Subscription (4 weeks) | — | `bounty_pass` | — |

**Coins are credited by the SERVER**, from this table, after Google confirms the
receipt. The client never says how many coins it should get.

---

## 6. Before you flip products to "Active"

- [x] Play Developer API enabled (§0a)
- [ ] **Service account invited in Play Console + granted financial access (§0b)**
- [ ] A build with Play Billing is uploaded to internal testing (§0c)
- [ ] All six in-app products created with **exact** IDs
- [ ] Subscription created *(skip until the Bounty Pass is built)*
- [ ] Prices set
- [ ] License testers added
- [ ] Backend deployed with the `PurchasesAndEntitlements` migration applied
- [ ] **Legal docs updated to present tense + version bumped** — `refund.md` §3 and
      `terms.md` §4 currently say purchases "may, now or in the future" be offered.
      The moment a product goes Active that becomes false.
      **Batch this with the Phase 4 ads rewrite so users are re-prompted once, not twice.**
- [ ] Play Console → **Data safety** and the **ads declaration** reviewed

---

## 7. Checklist for adding a NEW product later

1. Add it to `ProductDefinitions.cs` (backend) — what it grants.
2. Add it to `store_catalog.dart` (client) — how it's presented.
3. Create the SKU in the Play Console with the identical id.
4. If it grants a cosmetic, add that cosmetic to **both** `cosmetic_catalog.dart`
   (with `grantOnly: true` if it isn't coin-purchasable) **and**
   `CosmeticDefinitions.cs` — the server drops unknown cosmetic ids, which would
   silently take back something a paying customer owns.
5. `flutter analyze` + `flutter test` + `dotnet build`.
