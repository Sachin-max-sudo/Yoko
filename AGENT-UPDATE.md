# Agent wiring update — 0.3.0

5 October 2026. This is an action-pipeline repair, not completion of the entire Yoko 3 specification.

## Proven cause of text-only behavior

The saved mode was **ASK**. AgentEngine deliberately supplies no tools in ASK/ASSIST, so voice requests reached an answer-only model. The installed local `qwen2.5vl:3b` advertises `completion` and `vision`, not native `tools`. Removing a refusal sentence would not fix either issue. No hardcoded “text based AI” response was found in application sources.

## Changes

- A one-time release migration enables the user's explicitly requested **AUTO** mode. Per-action confirmations remain in place; this is not unrestricted autonomy. The main companion now shows AGENT versus ANSWER ONLY and allows changing it.
- Ollama capability metadata determines whether to use native tool calls or bounded schema-constrained orchestration. Completion-only models first select an operation, then fill that operation's argument schema. The result becomes the same normalized ToolCall used by the existing registry/approval/execution loop.
- Unknown tools, malformed envelopes and invalid arguments fail closed. No JSON/private reasoning is streamed into the avatar/chat. There are no natural-language command-to-action mappings for Chrome or YouTube.
- Tool observations retain their role inside the agent context; provider wire compatibility conversion happens in the provider adapter. The structured adapter can distinguish actual requests from subsequent tool evidence.
- Added named application launch, frontmost-app observation, typing, shortcuts, scroll, and approved Chrome/Safari URL opening/readback handlers. Apple Events and Accessibility permissions are enforced by macOS; dispatch alone is not proof of a website transaction.
- Provider connection testing displays actual native/structured/unknown action protocol. Structured mode is not falsely labeled native tool support.
- Main status prioritizes approval/agent progress over an open microphone. Mini voice mode and full mode keep the same AppModel/AgentEngine. Tiny/compact face click starts voice; double-click expands. Menu-bar mini access opens the compact voice panel.

## Actual verification

| Check | Evidence |
|---|---|
| Build | `swift build` passed |
| Normal suite | 121 tests discovered/executed by XCTest; 4 opt-in live tests skipped, 117 passed, zero failures |
| Real YouTube agent path | Explicit opt-in test used real local model, full shared registry, bounded approval, real WKWebView navigation; observed `https://www.youtube.com/`, persisted tool success, final model response. Passed before interruption; not repeated during resume. |
| Native Chrome launch | Separately invoked the real named application tool and independently read frontmost application. Google Chrome observed frontmost; passed. |
| Local Chrome intent | **Failed** model-only full-catalog tests: installed 3B vision model selected a website action or no action instead of app launch. This is not hidden by the normal suite's opt-in skips. |

## Known blocking limitation

The installed model can produce schema-valid but semantically incorrect actions. Native Chrome launch works, but the complete spoken “Chrome kholo” → correct tool selection → launch flow is **not accepted**. A native tool-capable model is recommended and still needs actual task testing. Model installation was proposed, but the question was interrupted before approval; no model was downloaded and no paid provider was configured.

The working YouTube test does not prove arbitrary multi-step reliability, video playback, music-result suitability, Chrome tab automation permissions, or full spoken STT/TTS/barge-in acceptance. The larger remaining requirements in `VERIFICATION.md` still apply: visual-model screen context, durable scheduling/reminders, dedicated deep research, full-duplex echo cancellation and production-quality character/voice acceptance are not completed by this change.

## Try the updated app

Open `dist/Yoko.app`. The header should show **AGENT**. Ask to open YouTube in Yoko's built-in browser and review the proposed tool/URL before allowing it. Inspect Tasks for the recorded tool result. For the installed small model, reject any proposal whose destination or operation does not match your request. Do not rely on a fluent final sentence as proof of execution.

To use another model, download it only with the user's approval, refresh Providers, select it, test its advertised capabilities, save, and perform real action tests. Credentials belong in Keychain, not chat.
