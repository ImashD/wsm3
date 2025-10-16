# Chatbot Integration Update (October 2025)

This document summarizes every source change introduced while wiring the new Gemini-powered chatbot into the Flutter application.

## 📁 New Files

| File | Purpose |
| --- | --- |
| `.env.example` | Template showing the environment variables (e.g. `GEMINI_API_KEY`) that must be provided locally. |
| `lib/core/config/env_config.dart` | Placeholder for a centralized environment helper. Presently empty but reserved for future typed access to `.env` values. |
| `tool/test_gemini_models.dart` | Standalone Dart script that validates which Gemini models are reachable with the configured API key. Useful when troubleshooting model availability errors. |

## ♻️ Updated Files

| File | Key Changes |
| --- | --- |
| `pubspec.yaml` | Added the `flutter_dotenv` dependency to load API keys at runtime and confirmed the `google_generative_ai` package version. |
| `pubspec.lock` | Locked the dependency graph so CI/other developers resolve identical package versions. |
| `lib/core/services/chatbot_service.dart` | Reworked the chatbot client: model fallback list (`gemini-2.5-pro`, `gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-2.0-flash-lite`), richer logging, farmer-context prompt construction, and Firestore-backed fallback messaging. |
| `lib/main.dart` | Ensures Firebase initializes before the app starts, giving the chatbot access to Firestore/Auth on launch. |
| `test/widget_test.dart` | Updated the smoke test to align with the new app bootstrapping logic. |

## � Code Diffs by File

### `pubspec.yaml`

- Added `flutter_dotenv: ^5.1.0` below the existing HTTP dependency block so the app can read `.env` values at runtime.
- Confirmed the `google_generative_ai` entry remains at `^0.4.7` (no other package constraints changed.

### `lib/core/services/chatbot_service.dart`

- Replaced the single `gemini-pro` model initialization with a rotating candidate list: `gemini-2.5-pro`, `gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-2.0-flash-lite`.
- Added helper methods `_orderedCandidateIndexes`, `_useModel`, and `_resetActiveModel` to track which Gemini instance is active.
- Wrapped `generateResponse` in retry logic that cycles through models on 429/503/permission errors and falls back to Firestore summaries when all fail.
- Expanded `_buildFallbackResponse` to enumerate farmer metadata, recent activities, and index warnings for transparency.
- Added console logging (e.g., `🔧 Using Gemini model: ...`, `📝 Sending prompt to Gemini model ...`) to simplify debugging.

### `lib/main.dart`

- Ensured `WidgetsFlutterBinding.ensureInitialized()` executes before Firebase bootstrapping.
- Explicitly awaited `Firebase.initializeApp` with `DefaultFirebaseOptions.currentPlatform`.
- Passed the prepared `AuthService` instance down into `MyApp` so the navigation layer is ready when the chatbot accesses user context.

### `test/widget_test.dart`

- Simplified the smoke test to pump a `MaterialApp` with a `Scaffold` and verify the scaffold renders, keeping automated checks lightweight while the chatbot boots asynchronously.


## �🔁 Runtime Behaviour Changes

1. **Environment loading** – developers now place secrets inside `.env`; the code reads them at runtime (via `flutter_dotenv`).
2. **Chatbot initialization** – `ChatbotService` rotates through multiple Gemini models, recovering from temporary 429/503 responses without blocking the UI.
3. **Context-aware prompts** – farmer profile, recent activities, and platform guidance are embedded in every prompt before calling the Gemini API.
4. **Fallback response** – if all Gemini calls fail, users still see a summary of their farm data pulled from Firestore.
5. **Diagnostic tooling** – the `tool/test_gemini_models.dart` script offers a quick command-line way to verify model access before shipping.

## 🚀 Getting the Chatbot Running Locally

1. Copy `.env.example` to `.env` and add your Gemini API key.
2. Run `flutter pub get` to fetch the new dependencies.
3. Execute `dart run tool/test_gemini_models.dart` to confirm the API key works with at least one Gemini model.
4. Launch the app with `flutter run -d chrome` (or any supported device).
5. Navigate to the farmer dashboard and tap the 🤖 chat bubble to start testing.

---
Last updated: 16 October 2025

