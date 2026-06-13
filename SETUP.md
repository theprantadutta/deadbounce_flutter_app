# Deadbounce Flutter App — Setup

Flutter + Flame + Cubit (flutter_bloc) in clean architecture. The backend lives
in the `deadbounce-dotnet-api` repo (see its SETUP.md).

## Layout

```
lib/
  core/
    config/    AppConfig — reads .env (URLs by kDebugMode, Google client id)
    network/   ApiClient (dio + bearer interceptor + error normalization)
    storage/   TokenStorage (flutter_secure_storage)
    router/    go_router setup + route constants
    theme/     design system: colors, typography, dimens, effects, theme
    widgets/   DbLogo, DbPrimaryButton/DbSecondaryButton, DbTextField
  features/
    auth/      domain (entities/repository/usecases) / data (firebase +
               remote datasources, repository impl) / presentation (AuthCubit,
               login & signup pages)
    splash/    brand splash + session restore
    home/      main menu (Play, settings/profile placeholders)
    game/      GamePage + DeadbounceGame (empty Flame arena)
```

## Prerequisites

- **`.env` at the repo root** — copy `.env.example` and fill in. It is loaded
  at startup by flutter_dotenv (and bundled as an asset, so a missing `.env`
  fails the build). Keys:

  | Key | Notes |
  |---|---|
  | `API_BASE_URL_DEV` | Used by **debug** builds (`kDebugMode`). `http://10.0.2.2:8394` for the Android emulator; your LAN IP for a physical device |
  | `API_BASE_URL_PROD` | Used by **release** builds — `https://deadbounce.pranta.dev` |
  | `GOOGLE_SERVER_CLIENT_ID` | The web OAuth client ID Google Sign-In uses to mint Firebase-verifiable ID tokens |

- `android/app/google-services.json` must exist (Firebase project
  `deadbounce-421b4`, package `com.pranta.deadbounce`). It is git-ignored —
  re-download from the Firebase console if missing.
- For **Google sign-in** to work at runtime you still need to (in the Firebase
  console): enable the Google provider, register your debug SHA-1, and
  re-download `google-services.json`. The code path is fully wired and will
  work as soon as the console side is done.
- Email/password and Anonymous providers must be enabled in
  Firebase Auth → Sign-in method.

## Run

```bash
flutter pub get
# Only needed after changing Drift tables/DAOs (generated *.g.dart is committed):
dart run build_runner build --delete-conflicting-outputs
flutter run          # debug → API_BASE_URL_DEV
flutter build apk    # release → API_BASE_URL_PROD
```

Configuration lives only in `.env` (read through
`lib/core/config/app_config.dart`); nothing else hardcodes URLs or client IDs.
See `CLAUDE.md` for the full architecture (offline-first Drift/outbox, the game
engine, meta systems) and `SFX_WISHLIST.md` for the audio still to drop in.

## Verify

```bash
flutter analyze   # must be clean
flutter test
```

## Auth flow

Every provider signs in with the Firebase client SDK first, then the data layer
exchanges the Firebase ID token at `POST /api/v1/auth/firebase` for a Deadbounce
JWT, stored in secure storage and attached as a Bearer header by `ApiClient`.
Splash calls `AuthCubit.restoreSession()` → `GET /auth/me` to resume sessions.

## Intentionally stubbed / next phase

- **Apple Sign-In** — button shows a "coming soon" snackbar; no client flow yet.
- **Gameplay** — `DeadbounceGame` renders only the arena (fixed 720×1280
  camera, glowing walls); the ricochet mechanic is the next pass.
- **Settings / Profile** — placeholder tiles on the home menu.
- **Logo & launcher icon** — the in-app logo is a styled Material icon
  (`airline_stops`) as a stand-in; final asset design and the launcher icon
  are out of scope for this pass.
- **Guest → account linking UI** — the backend already promotes anonymous
  users on `linkWithCredential`; the client UI for it comes later.
