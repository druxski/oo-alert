# OLX & Otomoto Alerts (Personal)

This is a personal-use Flutter app that:
- Aggregates latest listings from OLX and Otomoto (HTML parsing)
- Saves offers and price history locally (sqflite)
- Allows editing filters for each source (no need to edit code)
- Auto-refreshes every 60s (configurable in app)

IMPORTANT:
- This repo contains Flutter Dart sources and `pubspec.yaml`. To generate iOS/Android native folders, run:
  ```
  flutter create .
  ```
  in the project root (requires Flutter installed). Then replace the generated `lib/` and `pubspec.yaml` with the contents from this zip (already present).
- On macOS with Xcode: open `ios/Runner.xcworkspace`, set Signing Team, connect your iPhone and Run.
- If you use a free Apple ID the app will need re-installation every 7 days; a paid Apple Developer account (99 USD/yr) avoids that.

Privacy & legal:
- This app scrapes OLX and Otomoto pages for personal use. Do not distribute or run heavy scraping that violates site terms.

Files included:
- lib/ : Flutter app code
- pubspec.yaml : dependencies
- README.md : this file

