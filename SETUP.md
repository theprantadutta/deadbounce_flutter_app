# Deadbounce Flutter App — Setup

Flutter + Flame + Cubit (flutter_bloc) in clean architecture. The backend lives
in the `deadbounce-dotnet-api` repo (see its SETUP.md).

## Layout

```
lib/
  core/
    config/    AppConfig — API base URL from --dart-define
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

- `android/app/google-services.json` must exist (Firebase project
  `deadbounce-421b4`, package `com.pranta.deadbounce`). It is git-ignored —
  re-download from the Firebase console if missing.
- For **Google sign-in** to work at runtime you still need to (in the Firebase
  console): enable the Google provider, register your debug SHA-1, and
  re-download `google-services.json`. The code path is fully wired and will
  work as soon as the console side is done.
- The **web (server) OAuth client ID** is read automatically from
  `google-services.json` on Android (the `client_type: 3` entry Firebase adds
  when the Google provider is enabled). To pass it explicitly instead:
  `--dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com`.
- Email/password and Anonymous providers must be enabled in
  Firebase Auth → Sign-in method.

## Run

```bash
flutter pub get
flutter run                          # debug: API defaults to http://10.0.2.2:8394 (Android emulator → host)
flutter run --dart-define=API_BASE_URL=http://192.168.0.42:8394   # physical device → LAN IP
flutter build apk                    # release: defaults to https://deadbounce.pranta.dev
```

The API base URL lives only in `lib/core/config/app_config.dart` and the
`--dart-define`; nothing else hardcodes it.

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
