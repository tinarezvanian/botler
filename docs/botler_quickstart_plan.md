# Botler README quickstart — planning notes

This document records the repository audit, goals, and the README restructuring applied for developer-facing documentation.

---

## Repository audit (facts)

| Area | Implementation |
|------|----------------|
| **Entry** | `lib/main.dart`: `main()` → `WidgetsFlutterBinding.ensureInitialized()` → `AppEnv.init()` → `runApp(MyApp)`. |
| **UI** | `MaterialApp` → `ChatPage` (`StatefulWidget`). Send button appends `ChatMessage` (user), clears input, calls `generateResponse(input)`. Loading flag toggles spinner. Response appends `ChatMessage` (bot). |
| **Domain model** | `lib/model.dart`: `ChatMessage`, `ChatMessageType`. |
| **Config** | `lib/env/app_env.dart`: reads `.env.local` via `env_loader_io.dart` on IO; empty map on web. `--dart-define` overrides file when non-empty. |
| **HTTP / LLM** | `generateResponse()` in `lib/main.dart` only: OpenAI Completions-style JSON (`prompt`, `model`, …); parses `choices[0]['text']`. **Single vendor.** |
| **Deps** | `pubspec.yaml`: `flutter`, `http`, `window_size` (git), `cupertino_icons`. |
| **Platforms** | `ios/`, `android/`, `macos/`, `windows/`, `linux/`, `web/` — generated/native shells. |

**Not implemented:** multi-LLM routing, search backends, recommendation engines, deep-search orchestration beyond one HTTP round-trip.

---

## Documentation goals (from product brief)

1. Explain Botler as a **workflow**, not only a dependency bullet list.
2. Clear architecture overview + **sequential data flow** aligned with source files.
3. Rewrite **“What does Botler depend on?”** into workflow order with per-row developer detail (edit surface, I/O, repo paths, scope: iOS vs logic vs API vs optional).
4. State that **Cursor / VS Code** (with Flutter/Dart tooling) is sufficient for day-to-day work.
5. Explain **Swift, Gradle, CMake, HTML**, etc. as **Flutter-generated native shells**, not primary edit targets.
6. **Customize** section: concrete file/area pointers for provider swap, prompt shape, search, recommendations, orchestration, user context — labeled **implemented vs extension**.
7. **Mermaid** sequence diagram for tap → HTTP → UI.
8. Tone: practical, non-marketing; **no overclaim** on unimplemented features.

---

## Proposed README outline (implemented in `README.md`)

1. **Title + positioning** — Flutter chat client calling OpenAI Completions; iOS-oriented quickstart.
2. **Implemented today vs extension path** — short table or bullets (explicit separation).
3. **Working in this repository** — single IDE (VS Code / Cursor); `flutter` CLI; primary edits under `lib/`.
4. **Why Swift, Kotlin, Gradle, CMake, HTML appear** — embedders; avoid editing unless integrating native SDKs or signing.
5. **How Botler works** — layered architecture (UI → state → networking → config → transport → remote API).
6. **End-to-end workflow** — numbered steps: user input → `TextField` → `setState` / `_messages` → `generateResponse` → `AppEnv` getters → `http.post` → OpenAI → `jsonDecode` → `choices[0].text` → `setState` → `ListView` rebuild. Reference line-level anchors conceptually (`ChatPage`, `_buildSubmit`, `generateResponse`).
7. **Diagram** — Mermaid `sequenceDiagram`.
8. **Toolchain & dependencies (workflow order)** — expanded sections for each row:
   - Flutter SDK + Dart  
   - `pubspec.yaml` / `flutter pub get` / `pubspec.lock`  
   - Application code (`lib/`)  
   - Environment & secrets (`AppEnv`, `.env.example`, `.env.local`, `--dart-define`)  
   - `package:http`  
   - OpenAI REST API (external backend)  
   - Xcode + `ios/` (iOS build/sign/run)  
   - CocoaPods (`ios/Podfile`)  
   - Optional: `window_size` (desktop window title only)  
   - Minor: `cupertino_icons`  
9. **Customize into your own app** — tables mapping goal → **today vs extension** → suggested location (`generateResponse`, new `lib/services/`, orchestrator replacing single-call pattern, profile injection before prompt build).
10. **Repository layout** — condensed folder table (reference).
11. **Configure OpenAI API key** — shortened from current README; pointer to `.env.example`.
12. **Run on iOS** — keep command sequence (clone → pub get → env → pod → run).
13. **API response shape** — Completions vs Chat Completions caveat + parser location.
14. **Security + further reading** — retain essentials.

---

## README edits summary

- **Replace** the README body with the outline above (merge overlapping sections: old “What is Flutter?” becomes part of dependency/toolchain narrative).
- **Remove** redundant duplicate capability tables where the new “implemented vs extension” + “customize” sections subsume them.
- **Link** to this plan file from README optionally — user didn’t require it; omit to avoid doc clutter, or add one line under Further reading. I'll skip unless valuable — skip.

---

## Maintenance note

When code changes (e.g. Chat Completions migration), update:

- Step list under **End-to-end workflow**
- **API response shape**
- **Customize → LLM provider / prompt format** pointers

---

## Status

`README.md` was rewritten to match this outline in-repo; keep this plan file when adjusting documentation structure.
