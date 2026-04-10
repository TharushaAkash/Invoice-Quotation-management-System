// Firebase Configuration EXAMPLE
// This is an EXAMPLE file showing what your completed config should look like
// DO NOT use these values - they are just examples!
// Copy your REAL values from Firebase Console

import { initializeApp } from 'firebase/app';
import { getDatabase } from 'firebase/database';

// EXAMPLE Configuration (replace with YOUR actual values from Firebase Console)
const firebaseConfig = {
    // Example: "AIzaSyC1234567890abcdefghijklmnopqrstuv"
    apiKey: "AIzaSyC1234567890abcdefghijklmnopqrstuv",
    
    // Example: "etech-electricals.firebaseapp.com"
    authDomain: "etech-electricals.firebaseapp.com",
    
    // Example: "https://etech-electricals-default-rtdb.firebaseio.com/"
    // IMPORTANT: Get this from Realtime Database page, not from config!
    databaseURL: "https://etech-electricals-default-rtdb.firebaseio.com/",
    
    // Example: "etech-electricals"
    projectId: "etech-electricals",
    
    // Example: "etech-electricals.appspot.com"
    storageBucket: "etech-electricals.appspot.com",
    
    // Example: "123456789012"
    messagingSenderId: "123456789012",
    
    // Example: "1:123456789012:web:abcdef1234567890"
    appId: "1:123456789012:web:abcdef1234567890"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const database = getDatabase(app);

export { database };

/*
 * HOW TO FILL THIS FILE:
 * 
 * 1. Go to Firebase Console: https://console.firebase.google.com/
 * 2. Select your project
 * 3. Click gear icon (⚙️) → Project settings
 * 4. Scroll to "Your apps" section
 * 5. Click Web icon (</>)
 * 6. Copy the firebaseConfig object
 * 7. Paste it here, replacing the example values
 * 
 * IMPORTANT NOTES:
 * - databaseURL might be different - get it from Realtime Database page
 * - Make sure all values are in quotes ""
 * - Don't forget the commas between values
 * - Save the file after making changes
 */




