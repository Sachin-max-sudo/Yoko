# Yoko 0.2.1 — companion UI and microphone repair

5 October 2026. This update supersedes the earlier voice-gate/UI statements in `VOICE-AUDIT.md`; it is not a claim that the entire production specification is accepted.

## Verified microphone fault and repair

The latest screenshot reported **“The microphone has no usable audio format.”** Yoko's system errors showed VoiceProcessingIO routing an input-only microphone as its output device, aggregate creation failure `-10851`, and initialization failure `-10875`.

A first repair that directly reconfigured AVAudioEngine's HAL still failed the actual hardware smoke test: a startup configuration notification terminated capture with zero frames. That attempt was not accepted as a fix.

The final implementation replaces microphone routing with **AVCaptureSession + AVCaptureDeviceInput + AVCaptureAudioDataOutput**. It selects the microphone by its CoreAudio UID, copies real CMSampleBuffer PCM into bounded frames, and never changes the system output device or creates the broken voice-processing aggregate. Start/stop operations run off the main thread. Harmless startup configuration changes are no longer mistaken for disconnection.

### Actual packaged-app hardware result

An explicitly announced, eight-second microphone-only test ran on the affected external input:
- Permission: granted.
- Received format: **48,000 Hz, mono**.
- Received frames: **378,368**.
- Observed peak RMS: **0.3253**.
- Test completed; microphone stopped; no capture error recorded.

No audio was saved or sent to a model/server. This proves audio capture on that input during this test; it does not prove speech recognition, spoken-word accuracy or echo-free interruption.

Apple Speech permission was still **Not requested** in the test process. Use the microphone button or Voice Diagnostics → Test recognition and approve macOS Speech Recognition access. The original older generic “Retry” error cannot be retroactively attributed without its lost NSError details; new failures expose domain/code.

## New primary interface

- `CompanionView` is the actual app window root. The old chat/sidebar dashboard is no longer the launch experience.
- Genuine SceneKit/Metal three-dimensional character geometry: face, eyes, layered hair, fitted high-collar clothing, lighting and halo.
- Idle breathing, blinking, subtle head/gaze/hair motion; listening state driven by the real voice controller.
- Mouth and jaw movement are driven by measured TTS playback PCM amplitude, not random animation. This is amplitude-driven animation, not phoneme/viseme lip sync.
- Actual microphone/TTS amplitude history, explicit microphone-on indicator, central voice button, Stop, optional text entry, secondary conversation/settings panels.
- Transparent floating companion with intentional drag, right-click controls, small/medium/large sizes and mini-orb mode.
- Double-click floating companion to open the main screen. Click character to talk. Hover exposes Stop but never changes window position.
- Hidden companion windows release their hosting views so their SceneKit renderer is not kept active unnecessarily.
- Main render cap 30 fps; floating 15 fps; reduced-motion 10 fps with reduced motion intensity.

This is an original **procedural stylized character**, not a photoreal or externally authored premium rigged model. No external asset or engine was downloaded. Additional character art direction may be needed to match subjective reference quality.

## Checks actually performed

- `swift build`: passed.
- `swift test`: **82 XCTest tests passed**, zero failures.
- Release packaging, plist validation and local ad-hoc signature verification: passed.
- Latest `dist/Yoko.app` launched and stayed running.
- Character silent/speaking offscreen renders inspected.
- Actual application-owned SwiftUI/SceneKit view render inspected for layout; corrected the diagnostic renderer's flipped-coordinate composition. This is an app-owned view render, not a macOS screen capture. Screen-capture access was not bypassed.
- Hardware microphone-only test passed as documented above.

## Remaining acceptance boundaries

- Live Apple Speech transcription needs permission and a spoken test; not marked passed.
- Live end-to-end spoken AI response and acoustic interruption are not marked passed. The capture backend deliberately does not claim AEC; speaker leakage can trigger activity-based interruption. Use headphones for the first test.
- Floating drag, multi-display/fullscreen, mouse double-click and context menu paths compile but have not been interactively acceptance-tested.
- Native TTS PCM amplitude is connected to the avatar, but audible playback and latency still need user confirmation.
- The installed `qwen2.5vl:3b` passed a real local chat request and advertises completion/vision, not tools. Do not treat it as proven AUTO-mode tool support.
- The earlier full-product gaps (scheduling, dedicated deep research, comprehensive vision/computer use, etc.) in `VERIFICATION.md` remain.
- App is locally ad-hoc signed, not notarized or production-certified.

## Try it

```sh
open Yoko/dist/Yoko.app
```

Click the central microphone to talk, or hold Option + Space and release to finalize. Use the top-right floating-window button for desktop mode. Right-click the floating character for size, diagnostics and Stop. Chat/Tasks are in the bottom-right controls; other systems are in the ellipsis menu. Speech/AI failures remain visible and clickable rather than being covered by character animation.
