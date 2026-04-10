# 🚀 Flutter Setup Guide - E-Tech Electricals Desktop App

Complete guide to set up and build your Flutter Windows desktop application.

## 📋 Prerequisites

### 1. Install Flutter SDK

1. **Download Flutter**
   - Go to: https://flutter.dev/docs/get-started/install/windows
   - Download the Flutter SDK (zip file)
   - Extract to a location like `C:\src\flutter` (avoid spaces in path)

2. **Add Flutter to PATH**
   - Search "Environment Variables" in Windows
   - Edit "Path" variable
   - Add: `C:\src\flutter\bin` (or your Flutter path)
   - Click OK

3. **Verify Installation**
   ```bash
   flutter --version
   flutter doctor
   ```

### 2. Install Required Tools

Run `flutter doctor` and install what's missing:

- **Git** - Download from: https://git-scm.com/download/win
- **Visual Studio 2022** - Download Community Edition (free)
  - Install with "Desktop development with C++" workload
- **Android Studio** (optional, for mobile later)
  - Download from: https://developer.android.com/studio

### 3. Enable Windows Desktop Support

```bash
flutter config --enable-windows-desktop
flutter doctor
```

---

## 🔥 Firebase Setup

Follow the **FIREBASE_SETUP_GUIDE.md** to:
1. Create Firebase project
2. Enable Realtime Database
3. Get your Firebase configuration

---

## ⚙️ Configure Firebase in Flutter

**⚠️ IMPORTANT: Use WEB (`</>`) configuration, NOT Flutter configuration!**

See **FIREBASE_FLUTTER_SETUP.md** for detailed instructions.

1. **Open `lib/config/firebase_config.dart`**
2. **Get Web app config from Firebase Console:**
   - Go to Firebase Console → Project Settings
   - Click **Web icon (`</>`)** (NOT Flutter/Android/iOS)
   - Copy the configuration values
3. **Update the config file:**

```dart
class FirebaseConfig {
  static const String apiKey = "YOUR_API_KEY_FROM_WEB_CONFIG";
  static const String databaseURL = "https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com/";
  static const String projectId = "YOUR_PROJECT_ID";
}
```

**Most important:** The `databaseURL` - get it from Realtime Database page or Web app config!

---

## 📦 Install Dependencies

1. **Open Command Prompt in project folder**
2. **Run:**
   ```bash
   flutter pub get
   ```

This installs all packages from `pubspec.yaml`.

---

## 🏃 Run the Application

### Development Mode

```bash
flutter run -d windows
```

This will:
- Build the app
- Launch it on Windows
- Enable hot reload (save files to see changes instantly)

### Release Mode (Optimized)

```bash
flutter run -d windows --release
```

---

## 📦 Build Windows Executable (.exe)

### Option 1: Build Executable

```bash
flutter build windows
```

**Output location:**
```
build\windows\x64\runner\Release\
```

You'll find:
- `etech_electricals.exe` - Your application executable
- Other DLL files needed to run it

### Option 2: Create Installer (Advanced)

1. **Install Inno Setup** (free installer creator)
   - Download: https://jrsoftware.org/isdl.php

2. **Create installer script** (optional)
   - Package the .exe and DLLs into an installer

---

## 🎯 Project Structure

```
E tech/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                    # Data models
│   │   ├── invoice.dart
│   │   ├── quotation.dart
│   │   ├── inventory_item.dart
│   │   ├── expense.dart
│   │   └── income.dart
│   ├── services/                  # Firebase services
│   │   ├── firebase_service.dart
│   │   ├── invoice_service.dart
│   │   ├── quotation_service.dart
│   │   ├── inventory_service.dart
│   │   ├── expense_service.dart
│   │   └── income_service.dart
│   ├── screens/                   # UI screens
│   │   ├── main_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── invoices_screen.dart
│   │   └── ...
│   ├── widgets/                   # Reusable widgets
│   │   └── invoice_form_dialog.dart
│   └── utils/
│       └── app_theme.dart
├── pubspec.yaml                   # Dependencies
└── README.md
```

---

## 🐛 Troubleshooting

### "Flutter command not found"
- Add Flutter to PATH (see Prerequisites)
- Restart Command Prompt

### "No devices found"
- Run: `flutter devices`
- Make sure Windows desktop is enabled

### "Firebase not initialized"
- Check `lib/main.dart` has correct Firebase config
- Verify Firebase project is set up correctly

### Build Errors
```bash
flutter clean
flutter pub get
flutter build windows
```

### Missing Dependencies
```bash
flutter pub get
```

---

## ✅ Quick Checklist

- [ ] Flutter SDK installed
- [ ] Flutter added to PATH
- [ ] `flutter doctor` shows no critical issues
- [ ] Windows desktop enabled
- [ ] Firebase project created
- [ ] Firebase config updated in `lib/main.dart`
- [ ] `flutter pub get` completed
- [ ] App runs with `flutter run -d windows`
- [ ] Build successful with `flutter build windows`

---

## 🚀 Next Steps

1. **Test the application**
   - Create invoices, inventory items, etc.
   - Verify data appears in Firebase Console

2. **Customize**
   - Update colors in `lib/utils/app_theme.dart`
   - Add your company logo
   - Modify UI as needed

3. **Build for Distribution**
   - Run `flutter build windows`
   - Package the .exe file
   - Share with your team!

---

## 💡 Pro Tips

- **Hot Reload**: Press `r` in terminal while app is running to reload
- **Hot Restart**: Press `R` for full restart
- **DevTools**: Press `d` to open Flutter DevTools
- **Release Build**: Always test release builds before distributing

---

## 📚 Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Flutter Windows**: https://docs.flutter.dev/desktop
- **Firebase Flutter**: https://firebase.flutter.dev/

---

**Happy Coding!** 🎉

