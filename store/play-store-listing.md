# Deadbounce — Google Play Store Listing (ASO)

Copy for the Play Console **Main store listing**. Paste each field into its box.
Google Play has **no separate keyword field** — ranking keywords must live inside
the title, short description, and full description. Character budgets: **title 30,
short description 80, full description 4000**. No emojis/emoticons in the title or
short description (Play rejects them). Weave each priority keyword in naturally
**3–5 times** across the full description.

> How this was built: keyword targets came from the competing Play titles that
> index on this space — "Bullet Kills Ricochet", "Ricochet Squad", "Bullet
> Ricochet", "Ricochet Ranger" — plus the genre terms *arena shooter, roguelike,
> one-handed, bank shot, offline*. Validate/refine with real search volume in the
> Play Console (Acquisition → Store listing → keywords) or an ASO tool before you
> commit; treat this as a strong first draft, not final numbers.

---

## App title (≤30 chars)

**Recommended:** `Deadbounce: Ricochet Shooter` — 28 chars

Puts the brand first (fast-indexing slot) + the two highest-value keywords
("ricochet", "shooter").

Alternates:
- `Deadbounce: Ricochet Arena` — 26 chars (leans "arena shooter")
- `Deadbounce - Bounce Shooter` — 27 chars (targets "bounce")

---

## Short description (≤80 chars)

**Recommended (73):**
`No damage till it bounces! Bank neon bullets in a 1-handed arena shooter.`

Leads with the unmistakable hook, then packs "bounce", "arena shooter", and the
one-handed selling point. Reads as a benefit, not a keyword dump (Play's own
guidance: optimize the short description for the download decision, not stuffing).

Alternates:
- `Ricochet bullets off walls to win. A one-handed neon roguelike arena shooter.` (77)
- `Bank shots off the walls — bullets only kill after they ricochet. Play offline.` (79)

---

## Full description (≤4000 chars)

Play's full description is **plain text** — it does not render Markdown, so this
is written with plain paragraphs and UPPERCASE section headers (the common ASO
convention) rather than `**bold**`, which would show literal asterisks. Paste
everything between the rules verbatim. Current length ≈2.4k of 4000 — room to add
a testimonial or awards line later.

---
No damage till it bounces.

Deadbounce is a one-thumb neon arena shooter with a twist no other shooter has: a
direct hit does ZERO damage. Your bullets only turn lethal after they ricochet off
the walls — and every bounce adds more damage and more speed. Bank your shots,
bend the angles, and turn the whole arena into your weapon.

A RICOCHET MECHANIC THAT CHANGES HOW YOU PLAY
Forget point-and-shoot. In Deadbounce you read the walls, line up the bounce, and
bank the perfect shot. A live ricochet preview shows exactly where your bullet
will travel, so every kill is a shot you planned. Aim by dragging anywhere on the
screen — your thumb never covers the action — and tap to dash out of danger. Built
from the ground up to be played comfortably with one hand, in portrait.

SURVIVE THE WAVES
Hold the arena against relentless waves of bounce-themed enemies, each one asking
for a different angle: Drifters, Chargers, Splitters, wall-deadening Turrets,
shielded Warden bosses, armored Ironhides, healing Sawbones and reflective Mirrors.
Learn their patterns, bank the right ricochet, and keep the chain alive.

ROGUELIKE UPGRADES — BUILD YOUR RUN
Clear a wave and choose 1 of 3 upgrade cards. Split shots, incendiary trails,
rubber walls, ghost rounds, magnet bullets and more — they stack and combine into
a loadout that's yours. No two runs play the same. This is arena shooter meets
roguelike, tuned around the bounce.

MODES FOR EVERY MOOD
- Endless wave survival that ramps from kind to brutal
- Daily Challenge — one shared seed worldwide, a new puzzle every day
- Tournaments — rotating daily, weekly and monthly competitions for coin rewards
- Trick-Shot Gallery — pure bank-shot puzzles to sharpen your aim
- Leaderboards (daily, weekly, all-time) and 24 achievements to chase

SPEND YOUR COINS
Unlock permanent perks at The Gunsmith and show your style with visual-only
cosmetics at The Outfitter — bullet trails, gunslinger skins and arena themes.

PLAY ANYWHERE, ONLINE OR OFF
Deadbounce is fully playable offline after the first sign-in. Your progress syncs
to the cloud when you're back online, so your runs, coins and unlocks follow you.
No ads interrupting your run.

Neon-western style, tight one-handed controls, and a skill ceiling built entirely
on the bounce. Chalk your hands, partner — the walls are your best weapon.

Remember: bullets only bite after they bounce.
---

Priority keywords covered above (each appears naturally, not stuffed): ricochet,
bounce / bank shot, arena shooter, roguelike, one-handed, upgrades, waves,
leaderboard, daily challenge, tournament, offline, neon.

---

## Graphics assets (already in the repo)

- Phone screenshots: `play_store_screenshots/deadbounce-01.png` … `-08.png`
  (also lower-res marketing shots under `screenshots/`).
- Still needed in Play Console (not in repo): 512×512 app icon, 1024×500 feature
  graphic. Recommend baking the tagline "No damage till it bounces" into the
  feature graphic — it's the whole pitch in five words.

## Post-publish ASO loop

1. Ship this listing.
2. After ~2–4 weeks, read the Play Console keyword/search terms report.
3. Swap the lowest-performing keyword in the title/short description for a
   higher-volume term the report surfaces, and A/B test with Store Listing
   Experiments. Repeat.
