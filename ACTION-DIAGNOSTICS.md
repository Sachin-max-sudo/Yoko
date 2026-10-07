# Action-engine investigation — 0.3.1

5 October 2026. No avatar/colour/animation changes in this repair.

## Actual failure evidence

The existing local task audit showed the two latest action requests entering `open_app`, then `tool_stopped`, with `needs_review`. This proves dispatch reached the executor; it does not prove the microphone or model selection was correct. The previous implementation discarded the original exception, so the screenshot's historical exact exception/arguments cannot be recovered. It would be incorrect to attribute that screenshot conclusively to Accessibility: NSWorkspace app launching does not require Accessibility.

Inspection and live regression checks separately demonstrated that the installed completion/vision model can choose an application tool for a website or choose website navigation for Chrome. Dynamic installed-application grounding and argument validation now reject nonexistent app IDs before dispatch. This improves validation, but does not make the current model's semantics reliable.

## Focused repairs

- Added installed application inventory and bundle-ID constraints; validated Calculator resolution from actual macOS application bundles. Kept the executable named-app API while removing duplicate app-launch aliases from model-facing selection.
- Validate application arguments before exposing the provider's tool event and again in the native executor. Observed bundle URLs can be used when Launch Services lookup misses an installed app.
- Added stage diagnostics for request receipt, tool selection, dispatch, original NSError domain/code, verification and final failure stage. Technical errors are accessible in Action Diagnostics and privacy-marked OSLog. Diagnostics do not log raw microphone audio, automatic full transcripts, credentials or arbitrary shell payloads.
- Persist tool-error domain/code in task steps instead of losing all exception evidence. Native application resolution/launch messages are also shown in the session's diagnostic activity.
- Added Action Diagnostics with text command execution through the same AgentEngine, a separately labeled native Calculator executor test, actual permission snapshots, model metadata tests and persisted tool-step inspection. No pass badges are inferred from permission alone.
- Accessibility/Screen Recording/Automation Settings buttons lead to the relevant panels; permission observations refresh when returning to the app. Automation stays unknown/per-target until tested.

## Calculator end-to-end: PASSED

Command: `YOKO_LIVE_CALCULATOR=1 swift test --filter testCalculatorThroughFullAgent`

Actual path:

1. Request `Calculator kholo`.
2. Real local `qwen2.5vl:3b` inference with the full shared registry.
3. Model selected `open_app`, `bundle_id=com.apple.calculator`.
4. Test host approved only Calculator launch; no arbitrary tool approvals.
5. Native executor opened Calculator.
6. Observed PID, `running=true`, `frontmost=true`.
7. Tool verification persisted; final agent turn returned.

This is not a simulated model or a bypass of the agent. The separate native Calculator test button is explicitly labeled as executor-only to avoid confusing it with this end-to-end test.

## Build/test evidence

- Normal XCTest suite: 130 tests, 6 opt-in tests skipped, 124 passed, zero failures.
- Explicit real Calculator agent test: passed separately.
- Model-only full-catalog selection: Calculator and YouTube passed; **Chrome failed** by selecting a Google website instead of app launch.
- The earlier native Chrome launch/verification test remains evidence that the native executor can launch Chrome, not that the model's Chrome intent is fixed.

## Not complete

The full acceptance checklist is NOT met. Chrome natural-language selection still fails for the installed 3B vision model; some live observation-completion tests also reveal possible action replay. Approvals and bounded action counts remain necessary. No additional model was downloaded without permission. A native tool-capable model plus repeated live action tests is still required before claiming reliable multi-step action behavior.

The historical screenshot's exact lost exception is unknown. New diagnostics make subsequent failures attributable; do not equate adding diagnostic text with fixing all actions.

Spoken STT→agent→TTS, echo-safe interruption, permissions-dependent screen vision, YouTube search/playback and scheduled reminders are not passed by this Calculator test. The UI remains unchanged except for the required operational diagnostic surface.

## Use

Launch `dist/Yoko.app`, open ellipsis → Action Diagnostics. Enter `Calculator kholo` and Execute; review/approve the concrete Calculator tool. Then Refresh observations to inspect tool steps. Use “Test native executor: Calculator” only to isolate macOS launch from model selection. Latest errors are visible in Live activity; no API key belongs in the test-command box.
