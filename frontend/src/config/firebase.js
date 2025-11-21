import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyAsLk5YcVwhTQJ959cXDnbmsOEmGJtC49A',
  authDomain: 'etech-prod.firebaseapp.com',
  projectId: 'etech-prod',
  storageBucket: 'etech-prod.firebasestorage.app',
  messagingSenderId: '1063224122972',
  appId: '1:1063224122972:web:9ae130249229f5689a1099',
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export default app;


