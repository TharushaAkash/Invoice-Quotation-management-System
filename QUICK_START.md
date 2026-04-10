# Quick Start Guide - E-Tech Electricals Desktop App

## 🚀 Get Started in 5 Minutes

### Step 1: Install Node.js
- Download from: https://nodejs.org/ (version 18 or higher)
- Install and verify: Open Command Prompt and type `node --version`

### Step 2: Install Project Dependencies
Open Command Prompt in the project folder and run:
```bash
npm install
```
This will download all required packages (takes 2-3 minutes).

### Step 3: Set Up Firebase

1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com/
   - Click "Add project"
   - Name it "E-Tech Electricals" (or any name)
   - Follow the setup wizard

2. **Enable Realtime Database**:
   - In Firebase Console, click "Realtime Database"
   - Click "Create Database"
   - Choose location (e.g., "asia-south1")
   - Start in **test mode** (for development)

3. **Get Firebase Configuration**:
   - Click the gear icon ⚙️ → "Project settings"
   - Scroll down to "Your apps" section
   - Click the web icon `</>` to add a web app
   - Register app (name it "E-Tech Desktop")
   - Copy the `firebaseConfig` object

4. **Update Configuration File**:
   - Open `js/firebase-config.js` in your code editor
   - Replace the placeholder values with your actual Firebase config:
     ```javascript
     const firebaseConfig = {
         apiKey: "AIza...",           // Your actual API key
         authDomain: "...",            // Your actual domain
         databaseURL: "https://...",   // Your actual database URL
         projectId: "...",              // Your actual project ID
         storageBucket: "...",         // Your actual storage bucket
         messagingSenderId: "...",    // Your actual sender ID
         appId: "..."                  // Your actual app ID
     };
     ```

### Step 4: Run the Application
```bash
npm start
```
The application window should open! 🎉

### Step 5: Test It Out
1. Click "Dashboard" to see the overview
2. Click "Invoices" → "+ New Invoice" to create your first invoice
3. Check Firebase Console → Realtime Database to see your data!

## ✅ Verify Everything Works

**Check Firebase Connection**:
- Application should start without errors
- Open browser console (F12) - no Firebase errors should appear
- Try creating an invoice - it should save to Firebase

**Check Data in Firebase**:
- Go to Firebase Console → Realtime Database
- You should see your data appearing there!

## 🐛 Common Issues

**"Cannot find module 'electron'"**
- Run `npm install` again
- Make sure you're in the project folder

**"Firebase not initialized"**
- Check `js/firebase-config.js` has correct values
- Make sure Realtime Database is enabled in Firebase Console

**"Database permission denied"**
- In Firebase Console → Realtime Database → Rules
- Set rules to (for testing):
  ```json
  {
    "rules": {
      ".read": true,
      ".write": true
    }
  }
  ```
- Click "Publish"

## 📦 Create Windows .exe File

Once everything works, create an executable:

```bash
npm run build-win
```

The `.exe` file will be in the `dist` folder!

## 💡 Next Steps

- Start adding your business data
- Your data is stored in Firebase cloud
- Later, build a mobile app that uses the same Firebase database!

---

**Need More Help?** Check the main README.md for detailed instructions!
