# Yoko verification report

**Latest revision:** [COMPANION-UPDATE.md](COMPANION-UPDATE.md) documents the 0.2.1 animated companion interface, verified microphone capture repair and 82-test suite. Full-product acceptance remains incomplete.

**Historical baseline:** the voice sections and 56-test count below describe the original 0.1 build. The 0.2 voice rebuild, 79-test run, current Ollama check and remaining hardware gate are documented in [VOICE-AUDIT.md](VOICE-AUDIT.md); that report supersedes the old voice/shortcut statements. This file is retained to preserve the remaining full-product acceptance gaps.

Date: 4 October 2026 (Asia/Kolkata).

## Overall acceptance

**NOT COMPLETE against the supplied A–Z production specification.** Source, tests and a launchable native app exist. This report does not equate compilation, fixtures or process existence with verified end-to-end AI behavior. Missing implementations below are not permission or API-key problems.

Build artifact: `dist/Yoko.app` relative to this project. Source: `Sources/`. Tests: `Tests/YokoCoreTests/`. Setup: `README.md`.

## WORKING — actually exercised

| Check | Result and scope |
|---|---|
| `swift build` | Passed |
| `swift test` | 56 XCTest tests passed, zero failures |
| Release build | `zsh scripts/package.sh` passed |
| App plist | `plutil -lint` passed |
| Local signature | Ad-hoc `codesign --verify --strict` passed; not notarized |
| Application launch | Latest packaged app opened and its executable process remained alive after three seconds; not a visual UI acceptance test |
| SQLite | Persistent messages/memory/tasks, literal search, interrupted-task recovery, transactional deletion, export and credential-shaped settings rejection tested |
| Agent security/control | Unknown tools rejected; ASK/ASSIST do not dispatch; high-risk denial blocks execution; paid/cloud approvals tested using deterministic model fixtures |
| Routing | Local/free/priority preference, bounded pre-connection fallback, per-cloud-endpoint approval and no retry after partial output tested with fixtures |
| Recovery/cancellation | Read-only error feedback is bounded; uncertain writes halt; cancellation prevents dispatch and fallback |
| Native files | Authorized-root enforcement, writes/readback, mutations, symlink rejection and read bounds tested in disposable test directories |
| Shell | Actual subprocess exit/output bounds, timeout and cancellation tested using harmless fixture commands |
| Provider parsers | Ollama NDJSON, OpenAI-compatible SSE, fragmented calls, malformed/empty/truncated streams, endpoint policy and sanitized errors tested offline |
| Browser integration | Real WKWebView navigated to a local HTTP fixture, typed text, clicked a button, extracted changed DOM and returned PNG screenshot bytes; sensitive field and extra-argument rejection tested |
| Browser safety helpers | HTTPS/loopback URL policy, fixed-script argument encoding and risk classification tested |
| Knowledge | Actual local PDF, DOCX, RTF, HTML/text extraction, chunking, FTS5 ranking, persistence, changed-file replacement, deletion, cancellation and credential/path filtering tested |
| Connected registry | Unique tool names, memory save/search/delete and source-cited indexed retrieval through UnifiedTools tested |
| Voice primitives | VAD onset/end/silence/noise/max-duration tests; controller initialization/interrupt without microphone; invalid OCR input rejection |
| Services parsing | Search result URLs/time/limits, service endpoint checks, actual PNG decoding and invalid image rejection tested; no paid request performed |

The Swift Testing runner additionally reports zero Swift Testing tests; the 56 tests above are XCTest, not that empty runner.

Integration testing found and fixed WebKit's unsupported alternation in a content-rule regex. A registry integration test also caught the need to use a physical `/private/var` test path because indexing deliberately rejects symlink ancestors. The final entire test run passed after both fixes.

## CONNECTED CODE / UI — not runtime-certified

- Dashboard, orb, mini assistant, menu bar and global Option + Space share one AppModel/AgentEngine.
- Orb uses a fixed panel footprint. Only its native central drag handler writes panel coordinates; hover changes controls, not position. Drag position and display ID are persisted. Actual drag/hover/fullscreen/multi-display behavior was not observed interactively.
- Chat sends real streaming provider requests, with shared task records and approval UI. No real inference was exercised.
- Conversation search/rename/delete, Markdown export, memory controls and JSON data export are connected to tested storage APIs. Interactive controls were not driven by a GUI test.
- Keychain save/load/delete is called from provider/service UI; no live credential was supplied and no Keychain round-trip test was run.
- ScreenCaptureKit and Vision OCR, Apple Speech and AVSpeechSynthesizer paths compile and are connected. Live capture/recognition/playback was not run.
- Native app launch/focus/quit, clipboard, volume and Accessibility input have actual handlers but were not exercised against the user's applications.
- Browser UI displays the same WebKit object used by agent tools. Public websites/authentication flows were not tested.
- Search/image service buttons enter requests into the same approved agent loop; API calls were not run.

## REQUIRES PERMISSION

| Capability | Required grant / remaining verification |
|---|---|
| Microphone | macOS microphone permission; live audio capture not exercised |
| Speech | Speech Recognition permission, supported locale; Hindi/English/Hinglish not acceptance-tested |
| Screen OCR | Screen Recording permission; main-display capture not acceptance-tested |
| Computer input / UI tree | Accessibility permission; target-app result verification is incomplete |
| Apple events | Per-target Automation permission where macOS requires it |
| Files | Explicit folder grant in Yoko, plus any OS filesystem restrictions |

These grants must be made by the user. No permission state was fabricated or changed behind the user's back.

## REQUIRES API KEY

- OpenAI-compatible cloud chat: real profile endpoint, model and Keychain key.
- Brave Search: Keychain API key and enabled service configuration.
- Compatible image generation: provider key, supported image model, size and base64 response support. Charges require approval; successful generation was not tested.

## REQUIRES LOCAL MODEL

- Ollama chat/tool execution requires a running Ollama server and an installed suitable model.
- Live request to `http://127.0.0.1:11434/api/tags` failed to connect. No installation/download was attempted.
- Text/tool capability is not enough for vision; visual model inputs are not currently connected, even if a local vision model is installed.

## REQUIRES OPTIONAL SERVICE

Brave Search and cloud image generation are optional. Core local storage, keyword retrieval and native tools do not depend on them. Browser uses system WebKit and does not require a separately installed browser runtime. There is no implemented email/calendar service integration to configure in this build.

## KNOWN LIMITATIONS — missing or incomplete requirements

### Voice and multimodal

- Mandatory acoustic barge-in is absent. Recognition pauses during TTS; Stop is manual. Saying “Ruko” during playback is not supported.
- No Whisper/local STT fallback, cloud STT adapter, full-duplex echo cancellation, streamed AI-to-TTS response pipeline, voice selection/speed UI or validated mixed-language experience.
- Optional on-device wake-phrase gating exists internally, not as a complete exposed wake-word system.
- Screen attachment is OCR text, not visual model analysis. No image-bearing unified conversation context, image comparison, general audio attachments or visual computer-agent loop.
- Screen region capture, capture-selection UI and temporary frame history are absent; programmatic display/window capture exists but has not been permission-tested.

### Brain, tasks and automation

- Bounded multi-tool loop exists, but no separate structured plan/checkpoint model, specialty agent coordination, custom agent profiles, application skill catalog or project workspaces.
- No task queue, pause/resume/retry UI, scheduled tasks, reminders, conditional watchers, calendar/email integration, OS notifications, notification approval actions, daily briefing or proactive intelligence.
- Interrupted task history is recovered for review, not resumed from an exact durable execution checkpoint.
- Model requests use bounded recent context and keyword memory retrieval; no rolling conversation summary or semantic long-term memory. Memory lacks the requested category/confidence/source/importance metadata and automatic reflection.
- “Completed” records a finished agent run. Independent final goal verification is not universal. Some tool receipts explicitly verify only dispatch/process/DOM state.
- Required tool list is incomplete. Native keyboard supports a keycode and mouse supports a left click; shortcuts, typing, double-click, movement/scroll and comprehensive app controls are not all provided. Git inspection exists; a dedicated coding/debugging pipeline does not.
- No durable autonomous deep-research stages, pause/resume, evidence graph or independent claim cross-verification. Agent browsing/search can support research but is not the specified Deep Research system.

### Providers, retrieval and services

- Only Ollama and OpenAI-compatible chat protocols. No dedicated Gemini/Anthropic adapters.
- Router does not yet use measured cost, quality, latency or capability categories; no provider health dashboard, token/cost accounting, rate-limit cooldown or model downloads/removal.
- Limited safe connection fallback is tested; capability-aware cloud fallback and general rate-limit fallback are not implemented.
- Tool result messages are converted to untrusted text envelopes rather than preserving native provider tool-call IDs across turns; live model compatibility must be evaluated.
- Retrieval uses SQLite FTS5, not embeddings, vector search or reranking. No file watcher, per-index management inventory or scanned-PDF OCR pipeline.
- Image service requires one particular compatible payload; not all OpenAI-style image models accept it. No integrated generated-image gallery/style editor/regenerate/copy UI; saved files can be opened in Finder.

### UX, distribution and hardening

- No complete onboarding wizard, searchable settings, shortcut customization, display-specific position map, snap setting, system/light theme selector or full requested animation-state system.
- Menubar is always present; orb begins alongside the dashboard on launch rather than orb-only startup. Panel footprint is larger than the visible orb.
- No measured startup/memory/CPU targets, VoiceOver audit, sustained-load test or fullscreen/multi-display acceptance test.
- Cancellation is cooperative; an already dispatched click, completed write or accepted external request cannot be undone. Some platform calls cannot be force-cancelled immediately. Stop does not prove reversal.
- Approved shell is unsandboxed. File path checks reduce traversal risk but do not constitute a hardened descriptor-relative sandbox against all concurrent filesystem races. Secret detection is heuristic, not data-loss prevention.
- Export is not a complete restorable backup. Logical deletion is not secure physical erasure. No comprehensive credential scrubber for user-supplied chat/tool text.
- Local ad-hoc signing only. No notarization, Developer ID signing, updater, Intel/universal validation, release security audit or distribution installer.

## Requested ten end-to-end scenarios

| Scenario | Status |
|---|---|
| Voice → screen → vision → spoken app identification | NOT PASSED: no live permissions/model; visual model path absent |
| Chrome → YouTube → Punjabi music → volume 30% | NOT PASSED: no model or native interactive test; built-in browser is not Chrome |
| Folder → authentication code analysis → citations | Retrieval subsystem passed with real document fixtures; complete spoken/model flow NOT PASSED |
| Latest information → deep research report | NOT PASSED: no API key/model; dedicated research pipeline absent |
| Website preview → screenshot/text → analysis | Browser fixture pipeline passed; live AI analysis NOT PASSED |
| Prompt → generated image → save | Parser/file path implemented; live generation NOT PASSED |
| Previous-conversation/memory recall | Storage/search tests passed; model conversation recall NOT PASSED |
| Schedule tomorrow at 09:00 | NOT IMPLEMENTED |
| Confirm permanent deletion → delete → verify | File tool and approval tests passed separately; full live natural-language flow NOT PASSED |
| Say “Ruko” during TTS | NOT IMPLEMENTED as acoustic barge-in |

The application is not accepted as the complete requested production product on the evidence above.
