# OPERON optional Supabase bootstrap

The iPhone application stays in offline mode unless both build-time variables are supplied.

Project URL: https://wvtjaypoerwbknyqpxvh.supabase.co

Never insert a service-role secret into the mobile build or GitHub. Use only the project's **publishable key** when explicitly enabling the cloud.

After adding the dependency locally with `flutter pub add supabase_flutter`, commit the resulting `pubspec.yaml` and `pubspec.lock` to this branch. The GitHub branch currently does not contain this dependency. Until you commit it, the new bootstrap import will not compile on a fresh checkout.

Default offline commands:

```sh
flutter analyze
flutter test
flutter run --release
```

Opt-in initialization test (no cloud UI, no remote sync or real logins yet):

```sh
flutter run --release \
  --dart-define=OPERON_SUPABASE_URL=https://wvtjaypoerwbknyqpxvh.supabase.co \
  --dart-define=OPERON_SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Do not upload or synchronize existing local tasks. Use synthetic data only.
