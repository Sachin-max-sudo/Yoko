# Yoko voice-first mini update — 5 October 2026

## What was fixed

The old `Yoko.AudioCapture:7` path had been treated as a final microphone failure even though the capture backend had already been replaced. The latest controller now gates all user-visible microphone/listening state on the first valid PCM frame:

`capture requested → capture pending → first valid PCM → microphone active → STT starts`

Silence is still a valid frame; a zero-signal microphone is not confused with a missing stream. First-frame and stale-stream watchdogs perform up to three bounded recoveries, refresh devices, use a valid alternate input if the preferred device disappears, and never restart after Stop or a stale callback. Technical domain/code evidence stays in Diagnostics; the main companion gets friendly recovery text.

## Real packaged-app evidence

The latest deliberate local microphone smoke test passed:

- Permission: Granted
- Device: External Microphone
- Format: 48,000 Hz, mono
- Frames: 380,928
- Audio detected: peak RMS 0.0138
- First-frame gate: passed
- STT: not run because Apple Speech permission remains Not requested
- TTS: not run in this smoke test

This is actual captured audio evidence, not a glowing icon or permission-only check. No audio was saved or sent to a provider.

## Compact mini voice mode restored

Floating mode now has:

- **Tiny:** cute face orb; click expands to compact.
- **Compact:** ChatGPT-mini-style panel with cropped animated Yoko face, measured audio ring, live two-line transcript, Talk/Mic off, Stop, Continuous Conversation, text fallback and Expand.
- **Expanded:** main companion window; no old sidebar required.
- Drag is limited to the face/header so controls do not intercept movement.
- Right-click offers Talk, Expand, Compact, Tiny, Diagnostics, Settings, Stop and Quit.
- Position and size persist; actual voice amplitude drives the ring. Pending capture does not look like Listening.

Option + Space remains push-to-talk. Clicking Talk uses the same `VoiceController`; it does not create a separate fake mini microphone.

## Character and voice changes

The procedural SceneKit avatar is now softer and cuter: rounded face/cheeks, plum layered hair, natural eye highlights, blush, warm cardigan-like futuristic clothing and state expressions. Idle/listening/thinking/speaking/error states remain driven by the real controller. Mouth motion is still strictly measured TTS PCM amplitude; no random talking animation.

Native speech now selects the best installed matching-locale voice by actual quality/locale metadata and exposes the resolved name/notice. An optional HTTPS OpenAI-compatible TTS adapter exists behind explicit configuration, Keychain credentials and cloud consent; it is never silently selected. Native/system voices remain available, so subjective “human-like/cute” voice quality requires selecting and listening to an installed voice or configuring a real provider. No live cloud TTS call was made.

## Verification

- `swift build`: passed.
- `swift test`: **104 XCTest tests passed**, zero failures.
- Release app package, plist validation and ad-hoc signature: passed.
- Voice recovery/lifecycle tests cover first-frame gating, stream timeout/retry, device fallback, stale callback fencing, Stop, continuous conversation, partial-final safety and diagnostics redaction.
- Speech/TTS tests cover provider privacy gates, real WAV parsing, cancellation, voice selection, bounded chunks and measured PCM amplitude.

## Still requiring user action

Apple Speech permission must be granted and **Voice Diagnostics → Test recognition — no AI** must produce a real transcript before spoken STT is marked passed. After that, test actual spoken AI, TTS audibility and “Ruko” interruption with headphones. The application does not claim those live paths are verified merely because the microphone stream passed.
