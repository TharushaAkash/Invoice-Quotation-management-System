# E-Tech Electricals - Flutter Desktop Application

A modern Windows desktop application built with **Flutter** for managing invoices, quotations, inventory, expenses, and income. Uses **Firebase Realtime Database** for cloud storage.

## ✨ Features

- 🎨 **Modern Flutter UI** - Beautiful, native Windows application
- 📄 **Invoice Management** - Create, edit, and manage invoices
- 📋 **Quotation Management** - Create and track quotations
- 📦 **Inventory Tracking** - Manage stock with low stock alerts
- 💸 **Expense Tracking** - Record and categorize expenses
- 💰 **Income Tracking** - Track all income sources
- 📊 **Dashboard** - Real-time business statistics
- ☁️ **Firebase Cloud** - All data stored in Firebase

## 🚀 Quick Start

### Prerequisites

1. **Flutter SDK** (3.0+)
   - Download: https://flutter.dev/docs/get-started/install/windows
   - Add to PATH

2. **Firebase Account**
   - Sign up: https://firebase.google.com/

### Setup Steps

1. **Install Flutter** (see FLUTTER_SETUP_GUIDE.md)

2. **Set Up Firebase**
   - Follow: **FIREBASE_SETUP_GUIDE.md**
   - Update Firebase config in `lib/main.dart`

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the Application**
   ```bash
   flutter run -d windows
   ```

5. **Build Windows .exe**
   ```bash
   flutter build windows
   ```

## 📦 Building Windows Executable

```bash
# Build release version
flutter build windows

# Output location:
# build\windows\x64\runner\Release\etech_electricals.exe
```

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
├── services/              # Firebase services
├── screens/               # UI screens
├── widgets/               # Reusable widgets
└── utils/                 # Utilities & theme
```

## 📚 Documentation

- **FLUTTER_SETUP_GUIDE.md** - Complete Flutter setup instructions
- **FIREBASE_SETUP_GUIDE.md** - Firebase configuration guide
- **FIREBASE_VISUAL_GUIDE.md** - Visual Firebase setup guide
- **FIREBASE_QUICK_REFERENCE.md** - Quick Firebase reference

## 🎯 Usage

1. **Dashboard** - View business overview and statistics
2. **Invoices** - Create and manage customer invoices
3. **Quotations** - Create and track quotations
4. **Inventory** - Manage product inventory
5. **Expenses** - Record business expenses
6. **Income** - Track all income sources

## 🔧 Development

```bash
# Run in development mode
flutter run -d windows

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
```

## 🐛 Troubleshooting

See **FLUTTER_SETUP_GUIDE.md** for detailed troubleshooting.

## 📝 License

Created for E-Tech Electricals. All rights reserved.

---

**Built with Flutter 💙 | Powered by Firebase 🔥**
