# E-Tech Electricals Frontend

React.js frontend for E-Tech Electricals management system.

## Prerequisites

- Node.js 16+ and npm
- Firebase project configured

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure Firebase:**
   - Update `src/config/firebase.js` with your Firebase configuration
   - Enable Firebase Authentication (Email/Password)
   - Enable Firestore Database

3. **Configure API URL:**
   - Create `.env` file from `.env.example`
   - Update `REACT_APP_API_URL` with your backend API URL

4. **Run the application:**
   ```bash
   npm start
   ```

The app will be available at `http://localhost:3000`

## Build for Production

```bash
npm run build
```

This creates an optimized production build in the `build` folder.

## Deployment to Netlify

1. Build the project:
   ```bash
   npm run build
   ```

2. Deploy to Netlify:
   - Option 1: Drag and drop the `build` folder to Netlify
   - Option 2: Connect your Git repository to Netlify
   - Option 3: Use Netlify CLI:
     ```bash
     npm install -g netlify-cli
     netlify deploy --prod --dir=build
     ```

3. Set environment variables in Netlify:
   - `REACT_APP_API_URL`: Your backend API URL

## Features

- Dashboard with statistics and charts
- Customer management
- Inventory management
- Invoice creation and management
- Quotation creation and management
- Transaction tracking with money flow visualization
- Firebase Authentication


