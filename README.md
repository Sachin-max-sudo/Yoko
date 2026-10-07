# Yoko — native macOS agent

**0.3.1 action diagnostics:** [ACTION-DIAGNOSTICS.md](ACTION-DIAGNOSTICS.md) records the real full-agent Calculator test, original-error tracing, application-ID validation, and the still-failing local-model Chrome selection. No visual redesign was done in this iteration.

**Latest 0.3.0 action-pipeline update:** see [AGENT-UPDATE.md](AGENT-UPDATE.md). ASK-mode configuration and missing native tool support were the text-only blockers. Approved schema-constrained actions now reach real tools. Live YouTube navigation and native Chrome launch were tested separately; the installed model still fails Chrome intent selection. Full-product completion is not claimed.

**Voice-mini update (0.2.1):** read [VOICE-MINI-UPDATE.md](VOICE-MINI-UPDATE.md) first. The app now opens a native animated 3D companion, restores Tiny/Compact/Expanded ChatGPT-mini-style voice interaction, and gates Listening on a real first PCM frame. Latest packaged microphone smoke test passed with 380,928 frames. Speech recognition still requires a separate live Apple Speech permission/transcript test.

Native SwiftUI/AppKit application with a shared agent backend, local SQLite storage, model streaming, approval-gated tools, Apple Speech, document retrieval and an isolated WebKit browser.

**Status:** this is a buildable implementation, not a completed or production-certified implementation of the full supplied specification. Read [VERIFICATION.md](VERIFICATION.md) for tested behavior, untested integrations and missing requirements. No bundled model or simulated AI replies are used.

## Build and run

Requirements: macOS 14 or later, Xcode with Swift 6 toolchain. This build was compiled for Apple Silicon; Intel/universal builds are not verified. The package uses Swift 5 language mode.

```sh
cd Yoko
swift build
swift test
zsh scripts/package.sh
open dist/Yoko.app
```

The packaging script creates `dist/Yoko.app`, validates its plist, signs it ad hoc and verifies the signature. This is a local development signature, not a Developer ID/notarized distribution. Do not disable Gatekeeper. A distributable release needs your signing identity, entitlements review and notarization.

The app remains running when the dashboard closes. Use its orb or menu bar for the mini assistant, hold Option + Space for voice capture, and the menu bar to quit. Stop is available in the orb hover controls, chat composer, dashboard sidebar and menu bar.

## Local AI setup

1. Install Ollama from `https://ollama.com` and start it yourself. Yoko does not install services silently.
2. Download a model supported by your hardware and task, for example `ollama pull qwen3:8b` if that model is available in your Ollama registry. A tool-capable model is required for AUTO.
3. Verify `ollama list` shows the exact installed model tag.
4. In Yoko → Providers, keep protocol **Ollama**, URL `http://127.0.0.1:11434`, and choose **Refresh models**. Select the exact installed ID.
5. Test connection, then save profiles. The connection test checks model availability, not generation quality. Send a chat request to test inference.

No Ollama server was available during this build's live check. No model was downloaded. Local-first routing selects enabled loopback endpoints before remote ones, then unbilled profiles before billed profiles and numeric priority. Limited fallback occurs only before any response/tool event on known connection-establishment failures.

## Cloud AI setup

Add an **OpenAI-compatible** profile with the provider's documented HTTPS base URL (usually including `/v1`), exact model ID and billing designation. Enter the API key in the secure field and choose **Store in Keychain**. Save profiles and enable cloud access in Settings/Privacy.

Each remote or paid model run requires approval. Approval discloses that conversation context, tool output and relevant memories may leave the device. Unknown capability, pricing and token usage are not fabricated. Native Anthropic and Gemini protocols are not implemented; only Ollama and compatible Chat Completions/SSE endpoints are supported.

## Agent and file access

- ASK answers; ASSIST proposes; neither dispatches tools.
- AUTO exposes the registered tool catalog. Consequential actions require an exact action/argument approval.
- Permissions → Authorize a folder grants filesystem tools access for the current launch. No default folder access exists.
- Shell requires critical approval and an approved working directory. **Shell is unrestricted after approval and is not a filesystem sandbox.** Review the full command; never put credentials in it.
- Interrupted tasks retain their audit steps and become `needs_review`; actions with uncertain outcomes are not silently replayed.
- Task `completed` means the model/tool loop returned normally, not an independent proof of every natural-language goal.

## Voice and permissions

Launch the packaged `.app`, not just `swift run`, for microphone and speech purpose strings. Click Listen to request microphone and Apple Speech permissions. Choose English India, Hindi India or English US in Settings. Enable Speak final responses for Apple TTS and Conversation mode for continued listening.

Voice now defaults to requiring on-device Apple Speech. Apple server recognition is permitted only when you turn that requirement off. A separately running loopback whisper.cpp server can be selected or configured as a local fallback. Hardware interruption capture is implemented but not acceptance-tested; speaker leakage remains a known risk. No wake-word engine is enabled. See `VOICE-AUDIT.md` for accurate evidence and diagnostic steps.

For computer input, grant Yoko **Accessibility** in System Settings → Privacy & Security. For screen OCR, grant **Screen Recording** (or Screen & System Audio Recording, depending on OS), then restart if macOS asks. Automation grants are per target and checked by macOS when used. Yoko does not bypass permission dialogs.

## Documents and screen

Knowledge → Index files or folder extracts PDF, DOCX, RTF, HTML, text and code locally. SQLite FTS5 performs keyword-ranked chunk retrieval, not embedding-based semantic search. Reindexing replaces changed-file chunks transactionally. Scanned-PDF OCR and automatic file watching are not implemented.

Search the index and attach a cited chunk to ASK, or use AUTO's `search_knowledge` tool. The attachment button indexes; it does not automatically insert an entire document into chat. Screen attachment captures the main display and attaches local OCR text for review. Screen PNG data is not persisted; sent OCR text becomes conversation data. Visual-model image understanding is not connected.

## Browser, web and images

Browser is an ephemeral, isolated WKWebView, not your Chrome/Safari profile. Enter an HTTPS URL, open it and attach extracted text to chat, or use AUTO browser tools. Agent clicks and typing require approval. Password/token fields and CAPTCHA interaction are blocked for automation; interact manually. Downloads and popups are blocked, so some authentication flows are unsupported. No Playwright installation is required.

Services → Brave Search accepts a Brave API key stored in Keychain. Enable and save it, select AUTO, then Research. The shared agent can search and browse returned sources, but there is no separate durable deep-research pipeline or independent fact-checking engine. Search snippets are identified as snippets; they are not evidence that linked pages were read.

Services → Image generation selects an existing OpenAI-compatible profile and a provider-documented image model. The endpoint must accept `/images/generations`, `response_format=b64_json`, the selected size and return PNG/JPEG bytes. Save configuration and use Generate in AUTO; external disclosure/cost requires approval. Output is verified and saved under Application Support/Yoko/Generated Images. Open that folder to inspect/copy/save outputs. Providers that only return URLs or use different payloads are not supported.

## Data

Local databases: `~/Library/Application Support/Yoko/yoko.sqlite` and `knowledge.sqlite`. Generated images are under the same Yoko directory. Model credentials use macOS Keychain; UI preferences and nonsecret service selections use UserDefaults.

Privacy provides JSON export and logical deletion of conversations/tasks, memories and the knowledge index. Chat supports Markdown export, search, rename and deletion. Exports intentionally exclude credentials, but user-provided chat text/tool results can themselves be sensitive; review them before sharing. Deletion does not guarantee forensic SSD erasure or removal from backups. There is no telemetry.

## Architecture

`YokoApp` owns SwiftUI views, native windows, shared `AppModel`, orb dragging, menu bar and shortcut. The UI does not implement provider requests.

`YokoCore` contains:
- `Contracts`: normalized messages, tool schemas/calls/results, provider interfaces.
- `Agent`: bounded model/tool loop, context limits, approvals, routing, conservative recovery.
- `Store`: versioned SQLite conversations, messages, memories, task audit and preferences.
- `Providers` / `Keychain`: streaming NDJSON/SSE adapters and credential access.
- `UnifiedTools`: one registry composing native tools, browser, knowledge, memory, screen OCR and configured services.
- `NativeTools`: guarded files, app control, clipboard, system, Accessibility, shell and Git inspection.
- `Knowledge`: bounded document extraction, chunking, SQLite FTS5 search and citations.
- `Browser`: real WebKit navigation, DOM actions/extraction and screenshot capture.
- `Voice` / `ScreenVision`: Apple Speech/AVAudioEngine/VAD/TTS, ScreenCaptureKit and Vision OCR.
- `CreativeWeb`: Brave search and compatible image-generation requests.

External content is labeled untrusted. No model-supplied Swift/JavaScript/AppleScript evaluator exists; the shell tool is the explicitly approved exception for command execution. Provider secrets are never inserted into model messages by the application.
