# Model and Code License Ledger

## Bundled runtime models

None.

The app does not redistribute Stable Diffusion, LCM, FLUX, DreamLite, or another third-party model. `LCMInpaintingEngine` is an intentionally unavailable protocol implementation until a pinned model passes the physical iPhone 16 gate. Therefore the simulator build has no third-party model weights, runtime package, download, or model license obligation.

## Evaluated but not bundled

| Candidate | Source | Decision |
|---|---|---|
| Apple Core ML Stable Diffusion | https://github.com/apple/ml-stable-diffusion | Reference architecture; Apple sample code has its repository license, but model weights have separate terms. No code or weights copied. |
| Four-step Core ML LCM inpainting | https://huggingface.co/Dadm-n/stable-diffusion-v1-5-lcm-inpainting-coreml | Not bundled because no physical-device memory/latency validation was possible. |
| LCM DreamShaper parent | https://huggingface.co/SimianLuo/LCM_Dreamshaper_v7 | Evaluated only; not bundled. |

## Application code

The DishEdit application source was written for this project. It has no third-party runtime packages. Apple frameworks are linked through the iOS SDK.
