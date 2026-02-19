# Equb Mobile (Flutter)

## Setup
```bash
cd apps/mobile
cp .env.example .env
flutter pub get
```

## Run
```bash
flutter run
```

## Codegen (Freezed / Json)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Notes
- Environment is loaded from `apps/mobile/.env` using `flutter_dotenv`.
- `API_BASE_URL` is required at startup.
