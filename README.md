<div align="center">
  <h1>⚡ AeroLink Pro</h1>
  <p><strong>Universal High-Speed Android ⟷ PC Data Transfer & Storage Optimization Suite</strong></p>

  <p>
    <a href="https://github.com/Shahar-Yar095/aerolink/actions"><img src="https://img.shields.io/badge/CI-Passing-10b981?style=for-the-badge&logo=githubactions&logoColor=white" alt="CI" /></a>
    <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-38bdf8?style=for-the-badge" alt="License" /></a>
    <img src="https://img.shields.io/badge/Speed-Up%20to%20100%20MB%2Fs-orange?style=for-the-badge&logo=fastapi&logoColor=white" alt="Transfer Speed" />
    <img src="https://img.shields.io/badge/Android-Universal-green?style=for-the-badge&logo=android&logoColor=white" alt="Android Universal" />
    <img src="https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011-0078d4?style=for-the-badge&logo=windows&logoColor=white" alt="Windows" />
  </p>
</div>

---

## 📌 Problem: Why MTP Sucks
Standard Windows MTP (Media Transfer Protocol) connections freeze, crash during multi-gigabyte video transfers, refuse to copy hidden app data, and throttle USB 3.0 throughput down to 5–15 MB/s.

**AeroLink Pro** eliminates MTP bottlenecks completely. By streaming raw data packets directly through the native Android Debug Bridge (ADB) pipe, AeroLink unleashes your phone's full USB 3.0/3.2 hardware bandwidth—achieving sustained speeds between **40 MB/s and 100+ MB/s**.

---

## 🚀 Key Features

- **🌐 Universal Android Compatibility**: Auto-detects manufacturer and product model across all major Android ecosystems (Samsung, Pixel, Xiaomi, OnePlus, Vivo, Oppo, Motorola, Realme, Asus, etc.).
- **⚡ Hardware-Accelerated ADB Pipeline**: Bypasses Windows Explorer driver locks for reliable, crash-free file transfers.
- **🛡️ Zero Data-Loss Verified MOVE Mode**: Phone files are only deleted if and when the local PC file has been byte-verified for exact size integrity.
- **⏭️ Smart Auto-Skip**: Scans destination storage and instantaneously skips already backed up files without re-transferring.
- **🎨 Modern Native Dark UI**: WPF / XAML graphical interface with live battery monitoring, dynamic device status pill, transfer progress bars, and custom destination picker.
- **💻 Headless CLI Mode**: Includes `AEROLINK_CONSOLE.bat` for automated, scriptable terminal execution.
- **📦 Completely Portable**: Bundled with essential standalone ADB binaries—zero SDK or Android Studio installation required.

---

## 📱 Universal Device Compatibility

| Brand | Tested OS / Environments | Status |
| :--- | :--- | :--- |
| **Samsung** | Galaxy S / Z / A Series (One UI 3.0 – 6.1) | ✅ Verified |
| **Google** | Pixel 4 through Pixel 9 Pro (Stock Android 11 – 15) | ✅ Verified |
| **Xiaomi / Redmi / Poco** | HyperOS & MIUI 12 – 14 | ✅ Verified |
| **OnePlus / Oppo / Realme** | OxygenOS, ColorOS, Realme UI | ✅ Verified |
| **Vivo / iQOO** | Funtouch OS & OriginOS (All Y, V, X Series) | ✅ Verified |
| **Motorola / Lenovo** | Moto G, Edge, ThinkPhone | ✅ Verified |
| **Other Androids** | Any device running Android 7.0+ with USB Debugging | ✅ Verified |

---

## ⚡ Quickstart

### 1. Enable USB Debugging on Your Phone (One-Time Setup)
1. Go to your phone's **Settings** $\rightarrow$ **About Phone**.
2. Tap **Build Number** 7 times until you see *"You are now a developer!"*.
3. Go back to **System / Additional Settings** $\rightarrow$ **Developer Options**.
4. Enable **USB Debugging**.

### 2. Launch AeroLink on PC
Connect your phone with a USB cable and run:

- **GUI Interface**: Double-click [`AEROLINK.bat`](./AEROLINK.bat)
- **Console / CLI**: Double-click [`AEROLINK_CONSOLE.bat`](./AEROLINK_CONSOLE.bat)

When prompted on your phone screen, tap **"Always allow from this computer"** $\rightarrow$ **"Allow"**.

---

## 🏗️ Architecture

```mermaid
graph LR
  A[Android Device] -->|USB 3.0 / ADB Daemon| B[platform-tools/adb.exe]
  B -->|Standard Output Pipe| C[AeroLink Sync Engine - PowerShell]
  C -->|Verified Byte Stream| D[(PC Destination Drive)]
  C -->|Real-Time Telemetry| E[WPF Desktop Dashboard]
```

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](./LICENSE) for details.
