# Deadbounce — Audio Generation Prompts

Copy-paste prompts for generating each sound effect. Most audio generators make
**one sound per prompt** and don't remember context between runs, so **prepend the
STYLE BLOCK to every prompt** below.

## Where the files go

Save every generated file into:

```
deadbounce_flutter_app/assets/audio/
```

(Create the `assets/audio/` folder if it doesn't exist — that's the default
location `flame_audio` loads from.) Use the **exact filename** listed with each
sound. Once they're in, tell me and I'll add the `assets/audio/` entry to
`pubspec.yaml` and write the `flame_audio` implementation of `SoundManager` — no
gameplay code changes needed.

## Technical specs (apply to all)

- **Format:** `.wav`, **mono**, **44.1 kHz**, 16-bit
- **Level:** normalized to about **−3 dBFS** peak (loud but not clipping)
- **Trim:** cut all leading silence so the sound is instant on play
- Keep them **short** — `fire` and `bounce` fire many times per second, so any
  tail/reverb will muddy the mix. Dry and punchy beats lush.

---

## STYLE BLOCK — prepend this to every prompt

> Sound design for **Deadbounce**, a one-thumb neon arena shooter with a
> neo-western soul. The palette is **synthetic-arcade meets dusty analog**:
> punchy, retro-futuristic 8-bit/synthwave energy with a warm, slightly gritty
> Western edge (think a laser pistol forged in a desert saloon). Colors of the
> game are near-black, hot amber, and electric blue — translate that to sound as
> warm-but-electric, bright transients over a dark low end. Everything is short,
> dry, and impactful. Mono, no music, no long reverb tails.

---

## The 13 required sounds

### 1. `fire.wav` — player fires a bullet
> A sharp, snappy laser-twang pluck — the signature shot, heard constantly, so it
> must stay crisp and never fatiguing. A quick electric "pew" with a tiny metallic
> string-pluck attack and a fast downward pitch drop. ~120 ms, dry, bright.

### 2. `bounce.wav` — bullet ricochets off a wall
> A short, clean tonal "ping" — a bullet snapping off a hard neon wall. Bright
> metallic ding with a glassy synth resonance and an immediate cutoff. Tight and
> small so rapid bounces stack musically rather than muddy. ~80 ms.

### 3. `kill.wav` — enemy destroyed
> A satisfying geometric shatter-zap: a crunchy electric burst with a quick
> high-to-low sweep, like a glass neon shape exploding. Meaty but short, a little
> 8-bit grit on the transient. ~150 ms.

### 4. `chain.wav` — multi-kill (2+ enemies with one bullet)
> An escalating, rewarding riser layered over the kill sound — a bright synth
> sweep upward with an arcade "combo" sparkle on top, ending in a confident pop.
> Feels like a payoff. ~300 ms.

### 5. `hurt.wav` — player loses a heart
> A harsh negative thud: a dark, distorted low buzz with a downward pitch bend and
> a short gritty crunch. Clearly "bad" — punchy, no melody. ~200 ms.

### 6. `dash.wav` — player dashes between anchor points
> A quick whoosh-blip: a short filtered noise sweep with a synthetic "blip" tail,
> light and snappy, conveying a fast sidestep. ~120 ms.

### 7. `upgrade.wav` — upgrade card chosen
> A bright, confirming chime with a touch of Western shimmer — a warm bell/synth
> arpeggio (2–3 ascending notes) with a gentle golden sparkle, feeling like a
> reward unlocked. ~400 ms.

### 8. `warden_clang.wav` — bullet blocked by the Warden's shield
> A heavy metallic CLANG — a low-bounce bullet bouncing harmlessly off a thick
> energy shield. Big, ringing, slightly detuned metal hit with a fast damp, so it
> reads instantly as "no damage, try again." ~150 ms.

### 9. `warden_phase.wav` — Warden phase break / Last Stand revive
> A big dramatic moment: a heavy impact hit followed by a tension-release —
> a deep boom with a downward synth swell and a brief shimmering aftermath, like
> a shield shattering. Weighty and cinematic but still short. ~500 ms.

### 10. `coin.wav` — coin pickup collected
> A light golden sparkle: a short, bright two-note "ting" with a quick shimmer
> tail, clean and pleasant, classic arcade pickup with a warm glint. ~100 ms.

### 11. `wave_clear.wav` — wave cleared
> A short triumphant sting: a confident ascending synth-brass/bell flourish with a
> Western swagger, signaling "you survived, here come the spoils." Bright, not
> overlong. ~600 ms.

### 12. `ui_tap.wav` — menu button / tab press
> A subtle, clean UI click — a soft synthetic tick with a tiny amber-warm body.
> Understated and quick, never harsh. ~60 ms.

### 13. `game_over.wav` — run ends
> A somber neo-western outro stinger: a slow descending synth/lap-steel-style bend
> resolving into a low, dusty drone-hit. Melancholy and final, but compact — a
> last-stand-at-sundown feeling. ~800 ms.

---

## Optional (not wired yet — would elevate the feel)

### Bounce pitch variants (recommended if cheap to make)
Generate 3 versions of `bounce.wav` at rising pitch and save as
`bounce_1.wav` (low), `bounce_2.wav` (mid), `bounce_3.wav` (high). I'll map them to
the bullet's bounce count so escalating ricochets literally sound hotter.

### `ambient_arena.wav` — seamless arena ambience loop
> A low, seamless desert-wind-meets-synth-drone loop for the playfield — dark,
> spacious, barely-there tension. Must loop with no click. 8–20 s.

### `music_menu.wav` — seamless menu music loop
> A slow neo-western synthwave groove for the home/menus — moody, confident, a
> lone-gunslinger-at-a-neon-saloon vibe. Sparse beat, twangy synth lead, warm bass.
> Must loop cleanly. 30–60 s.

---

When the files are in `assets/audio/`, ping me and I'll wire it all up.
