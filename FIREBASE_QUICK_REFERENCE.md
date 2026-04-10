# 🔥 Firebase Quick Reference Card

## 📍 Where to Find Things in Firebase Console

### Your Project Dashboard
**URL**: https://console.firebase.google.com/

### Key Locations:
- **Project Settings**: Gear icon (⚙️) → Project settings
- **Realtime Database**: Left sidebar → Build → Realtime Database
- **Database Rules**: Realtime Database → Rules tab
- **Web App Config**: Project settings → Your apps → Web app

---

## 🔑 Firebase Configuration Values

### Where to Find Each Value:

| Value | Location |
|-------|----------|
| `apiKey` | Project settings → Your apps → Web app → Config |
| `authDomain` | Project settings → Your apps → Web app → Config |
| `databaseURL` | Realtime Database → Copy from top of page |
| `projectId` | Project settings → General → Project ID |
| `storageBucket` | Project settings → Your apps → Web app → Config |
| `messagingSenderId` | Project settings → Your apps → Web app → Config |
| `appId` | Project settings → Your apps → Web app → Config |

---

## 📝 Database Rules (Development)

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

**⚠️ Warning**: Only for development! Not secure for production.

---

## 🧪 Test Connection Checklist

- [ ] Firebase project created
- [ ] Realtime Database enabled
- [ ] Database URL copied
- [ ] Web app registered
- [ ] Config values copied to `js/firebase-config.js`
- [ ] Rules published
- [ ] `npm install` completed
- [ ] Application runs without errors
- [ ] Can create data in app
- [ ] Data appears in Firebase Console

---

## 🐛 Common Errors & Fixes

| Error | Fix |
|------|-----|
| "Firebase not initialized" | Check `firebase-config.js` has correct values |
| "Permission denied" | Update database rules to allow read/write |
| "Cannot find module" | Run `npm install` |
| "Database URL mismatch" | Copy exact URL from Realtime Database page |

---

## 📞 Quick Links

- **Firebase Console**: https://console.firebase.google.com/
- **Firebase Docs**: https://firebase.google.com/docs
- **Realtime Database Docs**: https://firebase.google.com/docs/database

---

## 💡 Pro Tips

1. **Keep your config file safe** - Don't commit it to public repositories
2. **Test mode is fine** - For development, test mode rules are okay
3. **Check the console** - Browser console (F12) shows helpful error messages
4. **Data structure** - Your data will be organized by type (invoices, inventory, etc.)

---

**Keep this reference handy while setting up!** 📌




