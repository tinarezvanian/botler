# Botler — Developer quickstart (iOS-focused)

Botler is a **Flutter** chat client: users send natural-language messages and receive replies from a **large language model (LLM)** over HTTP. This README is a **quickstart for mobile developers** who want to run and extend the app on **iOS**, and optionally grow it toward **multiple LLM backends**, **search-style prompting**, **personalized recommendations**, and **multi-step (“deep search”) workflows**.

---

## What is Flutter?

**Flutter** is a **free, open-source application SDK** from Google. You build the UI and logic in **Dart**; Flutter renders pixels using its own engine and produces **native ARM binaries** for iOS and Android (and optional desktop/web targets). Using Flutter is **free** — there is no Flutter subscription.

**Flutter is not:**

| Misconception | Reality |
|---------------|---------|
| An LLM or “AI API” | It does not generate text by itself. Botler uses Flutter only as the **app shell**. |
| A website | You can compile *some* Flutter apps for browsers (`web/`), but Flutter is primarily an **app framework**, not a hosted website. |
| A proprietary “connector” product | It is a dev toolkit; **your** code calls external APIs (here, OpenAI) over normal **HTTPS**. |

**Why Botler uses Flutter:** one codebase can target **iPhone, Android, desktop, and web**, sharing the same chat UI and networking code.

---

## What does Botler actually depend on?

| Piece | Type | Free or paid? | Why we need it |
|-------|------|---------------|----------------|
| **Flutter + Dart** | App framework + language | **Free** (open source) | Build and run the mobile/desktop/web UI and Dart logic under `lib/`. |
| **`http` package** | Dart library on [pub.dev](https://pub.dev) | **Free** | Sends JSON over HTTPS to OpenAI’s REST API. |
| **OpenAI HTTP API** | **Remote REST API** (cloud) | **Paid usage** ([pricing](https://openai.com/api/pricing/)); account + API key required | This is the **LLM backend**: prompts go in, generated text comes back. Not bundled inside the app. |
| **Xcode** | Apple IDE | Free from Mac App Store | Compile and sign the **iOS** app in `ios/`. |
| **CocoaPods** | iOS dependency manager | Free | Installs native iOS libraries Flutter bridges into. |
| **`window_size`** (plugin) | Flutter desktop helper | Free | Sets window title on macOS/Windows/Linux only; optional for pure iOS work. |

So: **Flutter = how the app runs on your phone.** **OpenAI’s API = where the intelligence runs**, accessed over the internet with an API key.

---

## Which LLMs does this repo use?

**Today, only one vendor is wired in code: OpenAI.**

| Topic | Detail |
|-------|--------|
| **Providers** | **OpenAI only** (via HTTPS `POST`). There is no Anthropic, Google Gemini, Azure OpenAI, or local Ollama integration in the default codebase. |
| **Endpoint style** | Configurable host/path; defaults match OpenAI’s **Completions**-style API. The app parses `choices[0].text` from the JSON response. |
| **Model name** | Set **`OPENAI_MODEL`** in `.env.local` (or `--dart-define`). It must be a model your OpenAI account allows **for that endpoint**. |

Adding **other LLMs** means adding new Dart code (new URLs, headers, request/response shapes) — similar to how OpenAI is called today — not a Flutter setting.

---

## How to set up API keys and “connections”

There is **no separate login screen** for OpenAI inside Botler. Configuration is **developer-side**:

1. **Create an API key** — [OpenAI API keys](https://platform.openai.com/api-keys) → create and copy a secret key.
2. **Enable billing / credits** — Real requests bill against your OpenAI account; manage limits in the OpenAI dashboard.
3. **Give the key to the app** (pick one approach):

| Approach | When to use | What you do |
|----------|-------------|-------------|
| **`.env.local`** | Local `flutter run` from project root on **iOS/Android/desktop** | `cp .env.example .env.local`, then set `OPENAI_API_KEY=sk-...`. Never commit this file. |
| **`--dart-define=OPENAI_API_KEY=...`** | CI, scripts, or **web** builds where file loading differs | Example: `flutter run --dart-define=OPENAI_API_KEY=sk-...` |

Non-empty **`--dart-define`** values **override** the file (see `lib/env/app_env.dart`). Other keys (`OPENAI_MODEL`, `OPENAI_API_HOST`, …) work the same pattern; see `.env.example`.

**“Connection” in practice:** the device uses **HTTPS** to `api.openai.com` (unless you override host). No VPN or special connector — just a valid **Bearer token** header built from your key.

---

## What this app does today

| Area | Behavior |
|------|----------|
| **UI** | Single chat thread: user bubbles vs assistant bubbles, loading indicator, scroll-to-latest. |
| **LLM** | Calls **OpenAI’s Completions API** (`POST` to a configurable host/path; default matches the legacy completions endpoint). Model name, temperature, token limits, etc. come from environment configuration. |
| **Secrets** | API keys and tuning live in **`.env.local`** (ignored by Git) or **`--dart-define=...`** overrides — never commit real keys. |

**Not implemented in code yet (but natural extensions of this repo):**

- **Multiple LLM vendors** (Anthropic, Gemini, local models): add service classes and route by feature or user setting.
- **Product search / catalog lookup**: treat user text as a query, call your search API or embeddings + vector DB, then summarize with an LLM.
- **Personalized recommendations**: store preferences or history (on-device or backend), inject them into prompts or use RAG over user-specific documents.
- **Deep-search workflows**: chain steps (plan → search → summarize → verify) in Dart or a small orchestration layer instead of a single `generateResponse` call.

The sections below map **folders** to responsibilities so you know where to plug those capabilities in.

---

## Technical detail: OpenAI request and response shape

Botler sends JSON (`model`, `prompt`, `temperature`, `max_tokens`, …) with **`Authorization: Bearer <OPENAI_API_KEY>`**. Tune defaults via `.env.example` / `.env.local`.

This codebase expects a **Completions-style** JSON reply (`choices[0].text`). If you switch to **Chat Completions** or another API shape, update the parser in `lib/main.dart`.

---

## Capabilities (today vs extension path)

| Capability | Today | Typical next step in this codebase |
|------------|-------|-------------------------------------|
| **Natural language input** | Full chat-style prompts to one endpoint. | Keep `ChatPage`; add intent routing before calling the LLM. |
| **Search-like behavior** | Users can *ask* questions in natural language; answers depend on the model only (no live web/corpus unless you add it). | Add `lib/services/search_service.dart`, call it from `generateResponse` or a new coordinator. |
| **Recommendations** | Not built-in. | Add user/profile storage + inject context into prompts or use RAG. |
| **Deep / multi-step workflows** | Single request/response per send. | Replace direct `generateResponse` with an orchestrator (tool calls, loops, multiple LLM requests). |

---

## Repository layout — what each folder is for

Flutter keeps **one codebase** for iOS, Android, desktop, and web. Folders map roughly like this:

| Path | Role |
|------|------|
| **`lib/`** | **Dart application code.** `main.dart` — app entry, chat UI, `generateResponse()` HTTP call. `model.dart` — `ChatMessage` / types for the transcript. `env/` — loads `.env.local` and exposes `AppEnv` (keys + model parameters). **Add** services (LLM routers, search, recommendations) here as new files or subfolders (e.g. `lib/services/`, `lib/features/chat/`). |
| **`ios/`** | **iOS native shell.** Xcode project (`Runner.xcworkspace`), `Info.plist`, signing, CocoaPods (`Podfile`). Required for building/running on iPhone Simulator and devices. |
| **`android/`** | Android Gradle project — same Flutter app; use when targeting Android. |
| **`macos/`**, **`windows/`**, **`linux/`** | Desktop embeddings — Botler also sets window titles on desktop via `window_size`. |
| **`web/`** | Web entry (`index.html`, icons). Note: `.env.local` is **not** read on web the same way as on iOS; use `--dart-define` for secrets there. |
| **`assets/`** | Bundled images (e.g. assistant avatar in chat). Declared under `flutter: assets:` in `pubspec.yaml`. |
| **`test/`** | Widget/unit tests. |
| **`.env.example`** | Template for **`.env.local`** (copy and fill; `.env.local` is gitignored). |

For **“multiple LLM APIs + search + recommendations + deep search”**, treat **`lib/`** as the integration layer: keep UI in widgets, move each external API behind a small class, and compose them from `generateResponse` or a dedicated orchestrator — without needing new top-level folders until the project grows.

---

## Prerequisites (iOS)

On your Mac:

1. **Xcode** from the Mac App Store (includes Simulator).
2. **Flutter SDK** — follow [Install Flutter](https://docs.flutter.dev/get-started/install/macos).
3. **CocoaPods** — `sudo gem install cocoapods` (or Homebrew `brew install cocoapods`).
4. **OpenAI API key** — create at [OpenAI API keys](https://platform.openai.com/api-keys); rotate keys if they were ever committed or leaked.

Verify:

```bash
flutter doctor -v
```

Accept Xcode licenses if prompted (`sudo xcodebuild -license`).

---

## Step-by-step: run Botler on iOS from this repo

### 1. Clone and enter the project

```bash
git clone git@github.com:tinarezvanian/botler.git
cd botler
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Configure secrets for local runs

```bash
cp .env.example .env.local
```

Edit **`.env.local`** and set at minimum:

```bash
OPENAI_API_KEY=sk-...your-key...
```

Optional: adjust `OPENAI_MODEL`, `OPENAI_API_HOST`, etc. See `.env.example` for all keys.

For **release / CI** or when `.env.local` is not present, pass defines (example):

```bash
flutter run --dart-define=OPENAI_API_KEY=sk-... --dart-define=OPENAI_MODEL=text-davinci-003
```

### 4. iOS pods

```bash
cd ios
pod install
cd ..
```

### 5. List devices and run on Simulator (example)

```bash
flutter devices
flutter run -d iPhone
```

Pick a concrete Simulator ID if needed:

```bash
flutter run -d "iPhone 16"
```

### 6. Run on a physical iPhone

1. Connect the device with USB; trust the computer on the phone.
2. Open **`ios/Runner.xcworkspace`** in Xcode.
3. Select the **Runner** target → **Signing & Capabilities** → choose your **Team** and a unique **Bundle Identifier**.
4. From the project root:

   ```bash
   flutter run -d <your-device-id>
   ```

   Or press Run in Xcode.

### 7. Release-minded build (example)

```bash
flutter build ipa --dart-define=OPENAI_API_KEY=... 
```

Prefer **secure** secret injection for production (e.g. CI secrets, not hardcoded in scripts). Never commit `.env.local`.

---

## Framework summary: using this repo as a starter for an iOS LLM app

1. **Bootstrap** — Flutter + Xcode + CocoaPods; `flutter doctor` clean for iOS.
2. **Configure** — `.env.local` + `.env.example`; document defines for CI/TestFlight.
3. **Run** — `flutter run -d <ios-device>`; iterate on `lib/main.dart` and split widgets/services as the app grows.
4. **Extend** — Add `lib/services/` for each backend (LLM A/B, search, user profile); keep `AppEnv` or replace with a stronger config layer.
5. **Ship** — Signing in Xcode, versioning in `pubspec.yaml`, `flutter build ipa`, App Store Connect.

---

## Security reminders

- Rotate any API key that ever appeared in Git history or logs.
- Keep **`.env.local`** out of version control; use `.env.example` only for non-secret defaults and documentation.

---

## Further reading

- [Flutter iOS setup](https://docs.flutter.dev/get-started/install/macos#ios-setup)
- [OpenAI API reference](https://platform.openai.com/docs/api-reference)
- [Flutter deployment — iOS](https://docs.flutter.dev/deployment/ios)
