# Outside or Else! — v1.0.0 Release Notes

**Outside or Else!** is a companion game designed to get you outdoors. Take care of your virtual pet, head outside for real-world exploration adventures, snap scrapbook memories, and chat with your companion entirely offline.

---

## 🌟 Key Features

- **Living Companion**: Nurture your pet with scritches, snacks, and attention. Your pet's mood, energy, and dialogue adapt to your routine.
- **Outdoor Adventures ("RELEASE THE LEGS")**: Quests and challenges encouraging outdoor excursions and active movement.
- **Scrapbook Memories**: Native camera integration to snap and archive real-world photos alongside your pet's journey.
- **Dynamic Sky & Day/Night Sync**: Living room ambience and sky lighting realistically mirror local solar progression.
- **Native Android Reminders**: Scheduled reminders (`POST_NOTIFICATIONS` + `RECEIVE_BOOT_COMPLETED`) keep your companion engaged even when the app is closed.
- **Optional Nearby Discovery**: Optional coarse location helps ground pet adventures in your local surroundings.
- **Privacy First & 100% Offline**: Saves are stored locally in IndexedDB and localStorage. No external account or telemetry needed.

---

## 🧠 Offline AI Engine

- **Bundled Neural Model**: Pre-packaged **Qwen3-0.6B** (`Qwen_Qwen3-0.6B-Q4_K_M.gguf`, 484 MB, SHA-256: `9acfc1e001311f34b4252001b626f2e466d592a42065f66571bff3790d4e1b14`).
- **Native llama.cpp CPU Runtime**: Custom C++ `pet_inference` native shared libraries compiled for `arm64-v8a`.
- **Zero Internet Required**: Chat and pet dialogue run 100% on-device CPU. The app never connects to any external LLM API or downloads weights at runtime.
- **Zero-Copy Memory Mapping**: GGUF weights are stored uncompressed (`ZIP_STORED`) inside the APK, allowing direct `mmap()` execution without duplicating disk space.

---

## 📦 APK Specifications

- **File Name**: `Outside-or-Else-v1.0.0.apk`
- **Package ID**: `com.outsideorelse.game`
- **Application Label**: `Outside or Else!`
- **Version**: 1.0 (versionCode 1)
- **File Size**: `502,918,510 bytes` (~479.62 MB)
- **Minimum Android Version**: Android 8.0 (API Level 26, `minSdkVersion 26`)
- **Target Android Version**: Android 16 (API Level 36, `targetSdkVersion 36`)
- **Supported Architecture**: `arm64-v8a` (64-bit ARM)
- **Signing Scheme**: APK Signature Scheme v2 (Signed with release RSA 2048-bit certificate)
- **Signer SHA-256**: `bad895e039c091b5d6738c148c192016879053af07e50332446f5797efb62f47`
- **APK SHA-256**: `c23c49021dbb171ad950f3276c1950ba16185e0281accc1856bb75b34934ba2e`

---

## 📲 Installation Instructions

### Method 1: Sideload via Android Debug Bridge (ADB)
Ensure USB Debugging is enabled on your phone and run:
```bash
adb install release/Outside-or-Else-v1.0.0.apk
```

### Method 2: Direct Phone Download / File Transfer
1. Download `Outside-or-Else-v1.0.0.apk` from the GitHub release to your phone or transfer it via USB.
2. Tap the APK file in your phone's File Manager or Downloads.
3. When prompted by Android, grant permission to **"Install unknown apps"** for your file browser.
4. Tap **Install** and launch **Outside or Else!**.

> **Note for developers/testers with existing debug builds:**
> Android OS enforces certificate matching for app updates. If you currently have the development debug build installed, attempting to install the release APK will report `INSTALL_FAILED_UPDATE_INCOMPATIBLE`. You must uninstall the debug build first before installing this release build.

---

## ⚠️ Known Limitations

1. **Architecture**: Only 64-bit ARM (`arm64-v8a`) devices are supported. 32-bit ARM devices or x86-based environments without ARM translation are unsupported.
2. **RAM Requirements**: Real-time on-device LLM inference requires ~1.2 GB of available RAM during active dialogue generation.
3. **Warm-up Latency**: Initial model load takes ~1.5–3 seconds on average Android hardware. Subsequent inference generates ~15–25 tokens/sec.

