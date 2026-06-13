# Deadbounce — Audio Wishlist

The game ships with a **silent no-op `SoundManager`** (`features/game/presentation/
game/systems/sound_manager.dart`). Every gameplay/UI event already calls
`sound.play(Sfx.x)`; dropping in real audio means implementing one class with
`flame_audio` — no gameplay code changes.

Please provide the following. **Format**: short `.ogg` (or `.wav`) one-shots,
mono, 44.1kHz, normalized to ~−3 dBFS, trimmed tight (no leading silence). Style:
**neo-western neon** — punchy, slightly synthetic/arcade, with a dusty analog edge.
Keep them short so rapid fire/bounces don't muddy.

| `Sfx` value | Event | Length | Style notes |
|---|---|---|---|
| `fire` | Player fires a bullet | ~120ms | Sharp pluck/twang; the signature shot — gets spammed, must stay crisp |
| `bounce` | Bullet hits a wall | ~80ms | Short tonal "ping"; pitch could rise with bounce count (or send 3 variants: low/mid/high) |
| `kill` | Enemy destroyed | ~150ms | Satisfying crunch/zap; geometric "shatter" |
| `chain` | Multi-kill (2+) | ~300ms | Bigger, rewarding riser — layered over `kill` |
| `hurt` | Player loses a heart | ~200ms | Harsh negative thud/buzz |
| `dash` | Player dashes between anchors | ~120ms | Quick whoosh/blip |
| `upgrade` | Upgrade card chosen | ~400ms | Bright confirming chime, slight western shimmer |
| `wardenClang` | Bullet blocked by Warden shield | ~150ms | Metallic CLANG — clearly "no damage" |
| `wardenPhase` | Warden phase break / Last Stand save | ~500ms | Heavy impact + tension drop; a big moment |
| `coin` | Coin pickup collected | ~100ms | Light golden sparkle |
| `waveClear` | Wave cleared | ~600ms | Short triumphant sting |
| `uiTap` | Menu button / tab | ~60ms | Subtle click |
| `gameOver` | Run ends | ~800ms | Somber western outro stinger |

### Optional (not wired yet, would elevate the feel)

- **Ambient loop**: low desert-wind / synth drone for the arena (seamless loop).
- **Menu music loop**: slow neo-western synth groove for home/menus.
- **Bounce pitch variants**: 3–4 `bounce` samples at rising pitch so escalating
  ricochets sound hotter (mapped to bounce count in `BulletComponent._onBounce`).

When ready, drop files in `assets/audio/` and I'll wire the `flame_audio`
implementation + the `pubspec.yaml` asset entries.
