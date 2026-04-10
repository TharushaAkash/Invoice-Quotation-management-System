# ⚡ Quick Fix: Visual Studio Components

## ❌ The Problem: Unsupported Visual Studio Version
You are using **Visual Studio 2026 (Version 18.x)**, which is a **Preview** version.
Flutter and CMake do not yet support this version, causing the error:
> `Generator Visual Studio 16 2019 could not find any instance of Visual Studio`

## ✅ The Solution: Install Visual Studio 2022

You must install the **Stable** version of Visual Studio 2022 (Version 17.x).

### 1. Download Visual Studio 2022
- Visit: [visualstudio.microsoft.com/downloads](https://visualstudio.microsoft.com/downloads/)
- Download **Visual Studio 2022 Community** (Free).

### 2. Install Required Workloads
During installation, ensure you select:
- [x] **Desktop development with C++**

### 3. Verify & Run
After installation:
1. Run `flutter doctor` (Ensure it detects "Visual Studio Community 2022")
2. Run `flutter run -d windows`

---

**Note:** You can keep your VS 2026 Preview installed, but you *must* have VS 2022 installed for Flutter to work.


