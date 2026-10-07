# Yoko 2 voice-first audit and acceptance gate

**Superseded follow-up:** [COMPANION-UPDATE.md](COMPANION-UPDATE.md) records the subsequent concrete routing failure, AVCaptureSession replacement, successful hardware capture test and new 3D companion UI requested in the follow-up. The audit below preserves the earlier findings; its AVAudioEngine and “avatar not built” statements describe that earlier revision.

Updated 5 October 2026 (Asia/Kolkata). This is a foundation/diagnostic build, not the finished 3D companion redesign.

## Evidence before changing the interface

The old voice implementation used **Apple Speech only**. It discarded NSError domain/code and surfaced `localizedDescription` (such as “Retry”) inside a generic instruction to retry/check everything. That lost the evidence required to distinguish recognizer-service errors from microphone or permission failures.

Observed code problems, not inferred hardware diagnoses:
- Recognition cleanup stopped AVAudioEngine, removed its tap and recreated the recognition request for every utterance.
- Speaking explicitly cleaned up microphone recognition, so acoustic interruption could not work.
- Recognition failures stopped the entire conversation immediately; there was no STT provider fallback or bounded recovery.
- VAD sensitivity and silence timing were fixed. There was no input selector or microphone-only test to distinguish absent audio from STT failure.
- The app discarded voice utterances while an agent task was busy.
- Option + Space toggled the text panel rather than implementing press/release voice capture.
- On-device capability was treated as sufficient to require on-device recognition, without reporting runtime service failures or letting the user explicitly select server-backed Apple recognition.

The original screenshot's exact failure **cannot be established retrospectively**: its error code and audio evidence were not retained. None of the above is presented as proof that a specific missing asset, permission or device caused that historical “Retry”.

## Live checks performed

- Ollama's loopback `/api/tags` returned the installed `qwen2.5vl:3b` model.
- A real local `/api/chat` request containing only “Reply with exactly OK.” returned `OK.`. This verifies local text inference, not tool calling or speech recognition.
- Advertised capabilities were `completion` and `vision`, **not tools**. Do not equate this model's successful chat with AUTO-mode compatibility.
- In the rebuilt packaged app's own process, Microphone and Apple Speech authorization both reported **Not requested**. Input devices were enumerated, but capture was not started. No permission grant or audio reception is claimed.
- Apple reported recognizer availability and on-device capability for `en-IN`; this does not verify service assets or actual transcription.
- Re-signing an ad-hoc app can change how macOS treats prior grants. The current permission snapshot does not establish the old app's permission state.
- Private runtime diagnostics stay under the workspace's private `.opencode/omnirush/diagnostics` location; this document contains only a redacted evidence summary, not recordings or raw logs.

## Replaced foundation

`AudioCaptureManager`: reusable AVAudioEngine, device enumeration/selection, actual format and frame count, copied bounded frame stream, permission validation and device/configuration-change errors. No microphone starts during initialization.

`SpeechProvider`: independent Apple Speech and loopback whisper.cpp adapters. Apple partial/final events preserve safe error domain/code. Whisper requests use real bounded WAV/multipart input, periodic partial re-transcription and a final request. No model or server is silently installed. Remote Whisper endpoints and redirects are refused.

`VoiceController`: one capture stream per started session, configurable VAD/silence threshold, separate recognizer rotation, bounded recovery, optional local Whisper fallback with ephemeral audio replay, speech-test mode that never dispatches an agent, cancellation fencing, microphone-only test and explicit diagnostic evidence.

`NativeSpeechPlayback`: native synthesis to PCM, controlled audio-player playback and RMS measured on the render path. The amplitude is available for the later avatar; it is not a random animation or synthesis callback estimate. Stop flushes pending audio and resets the meter.

Interruption listens during an explicitly started voice session/response and uses sustained microphone activity to stop playback while retaining capture. The app can cancel a running agent and queue the new final utterance instead of discarding it. This is **not a certified acoustic echo canceller or speaker-identification system**. Separate capture/playback engines and hardware-dependent voice processing can still allow speaker leakage; test with headphones before speaker mode. No latency or hardware-reliability claim has been made.

## Diagnostic controls

Menu bar → **Voice Diagnostics**, or the temporary diagnostic navigation entry:

1. Select the intended input device, preferably the built-in mic for the first test.
2. **Test microphone · 8 seconds**. Grant access and speak normally. Observe actual RMS and received frames. A device list alone is not a successful mic test.
3. Choose `en-IN` or `hi-IN` and **Test recognition — no AI**. Grant Speech access if using Apple. Observe a final transcript and, on failure, the original domain/code.
4. **Test TTS**. The PCM meter confirms rendering; the user still needs to confirm audibility.
5. With headphones, **Test interruption** and say “Ruko” while the sample plays. Verify playback stops and the following speech is transcribed. Test speaker mode separately for false interruption.
6. **Copy diagnostic report** to share the results. It omits transcript/audio and credentials.
7. Once these pass, test actual AI conversation; hold Option + Space to capture and release to finalize. Configure AUTO only with a model that supports tools.

Changing the Apple on-device requirement to OFF explicitly allows Apple's server recognition. It is never used as a silent privacy-changing fallback. Whisper fallback only goes to the explicitly configured loopback endpoint.

### Optional local Whisper server

Use a separately installed, trusted whisper.cpp build and a multilingual model, not an English-only `.en` model for Hindi/Hinglish. Follow that installed version's own build/model instructions. A typical invocation after setup is:

```sh
./build/bin/whisper-server -m ./models/ggml-base.bin --host 127.0.0.1 --port 8080
```

The exact executable/model paths depend on the installation. Check `whisper-server --help` for its supported flags. In Yoko set `http://127.0.0.1:8080/inference`, select Local Whisper or enable it as fallback, then run the recognition test. This build has not tested an actual installed whisper.cpp server. Adapter tests use isolated HTTP fixtures, not a fake production recognizer.

## Checks

- `swift build`: passed.
- `swift test`: **79 XCTest tests passed**, zero failures.
- Release package/plist/ad-hoc signature: passed.
- Latest packaged app launched into diagnostics; its process stayed running.
- New tests cover PCM/meter/copy ownership, format validation, STT cancellation fences, original error classification, loopback policy, resampling/WAV bounds, multipart requests, finalization, bounded TTS queues, interruption threshold, recovery budget, and cancelled push-to-talk.
- No test grants system permissions, opens the microphone or plays sound automatically.

## Acceptance gate: NOT PASSED YET

User-initiated hardware tests are required to establish the current voice fault and validate the repair. The current app reports permission not requested, so there is no live capture/transcription evidence yet. Do not start avatar/UI polish or call the voice system reliable based on passing unit tests.

The premium 3D model, companion-first window/navigation, head/eye/mouth animation and transparent avatar modes are **not built in this revision**. Existing backend gaps listed in `VERIFICATION.md` also remain unless explicitly superseded here. Existing application graphics outside the new diagnostic controls were not polished as a substitute for fixing voice.
