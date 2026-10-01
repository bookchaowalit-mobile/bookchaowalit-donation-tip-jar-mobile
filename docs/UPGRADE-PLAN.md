# Upgrade Plan — Donation Tip Jar Mobile

## Current state

Score: 7.5/10 — integer-cent tip/split maths with strict input parsing, error states, a11y guideline tests and fail-closed signing; no persistence, currencies, icon or E2E flow yet.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Remember the last tip percentage and people count (shared_preferences).
- Currency selection with correct minor units (e.g. JPY has none).
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail).
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 3)

- Bug fix: amounts stripped every comma, so a European-style `12,50` was read as 1,250.00 and `1,2` as 12.00. Commas are now accepted only as thousands separators (`1,234.56`); anything else shows the amount error.
- Bug fix: the custom tip used `int.tryParse` (accepting `0x10` as 16 and `+5`), and while it showed "Use 0 to 100" the card still displayed a total computed from the preset percentage. New `parsePercent` accepts plain 0–100 digits and the result card is hidden while either input is invalid.
- Edge-case unit tests: comma placement, amount limits and near-misses (Arabic-Indic digits, `.5`, `+5`), percent parsing, zero bill/tip, shares summing to the total and differing by at most one cent over many bills/splits, round-up extra, 100% tip on the largest bill.
- Accessibility: people count is a live region. Widget tests: invalid custom percent hides the result, comma amount error, round-up extra, disabled "fewer people" at one, a11y guidelines, 200% text scale.
- Bug fix (accessibility): the "People" row overflowed by 57 px at 200% text size on a 360 px-wide phone; the label now wraps. The text-scale widget test runs at phone width (it previously used the 800 px default test surface).

## Done in pass 2

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).


## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (work out a tip or donation, split it between people and round it sensibly) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
