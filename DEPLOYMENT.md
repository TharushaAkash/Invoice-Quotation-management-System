# Deployment Guide - E-Tech Electricals

This guide provides step-by-step instructions for deploying the E-Tech Electricals application.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Backend Deployment](#backend-deployment)
4. [Frontend Deployment](#frontend-deployment)
5. [Environment Configuration](#environment-configuration)
6. [Post-Deployment](#post-deployment)

## Prerequisites

- GitHub account
- Firebase account
- Render/Railway account (for backend)
- Netlify account (for frontend)
- Git installed locally

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "E-Tech Electricals"
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Enable Firestore

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Select "Start in production mode"
4. Choose a location (closest to your users)
5. Click "Enable"

### 3. Enable Authentication

1. Go to "Authentication" > "Get started"
2. Click "Sign-in method" tab
3. Enable "Email/Password"
4. Click "Save"

### 4. Get Service Account Key

1. Go to Project Settings (gear icon)
2. Click "Service accounts" tab
3. Click "Generate new private key"
4. Save the JSON file securely
5. **Important**: This file will be used in backend deployment

### 5. Get Web App Config

1. In Project Settings, go to "General" tab
2. Scroll to "Your apps" section
3. Click the web icon (`</>`)
4. Register app (name: "E-Tech Web")
5. Copy the Firebase configuration object

## Backend Deployment

### Option 1: Render

#### Step 1: Prepare Repository

```bash
# Initialize git if not already done
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-github-repo-url>
git push -u origin main
```

#### Step 2: Deploy on Render

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New" > "Web Service"
3. Connect your GitHub repository
4. Configure:
   - **Name**: `etech-backend`
   - **Environment**: `Java`
   - **Build Command**: `cd backend && mvn clean install -DskipTests`
   - **Start Command**: `cd backend && java -jar target/electricals-backend-1.0.0.jar`
   - **Plan**: Free tier (or paid)

#### Step 3: Add Environment Variables

In Render dashboard, go to "Environment" tab and add:

- `FIREBASE_CONFIG`: Paste the entire content of your service account JSON file

#### Step 4: Update Firebase Config Code

You may need to modify `FirebaseConfig.java` to read from environment variable:

```java
@Value("${FIREBASE_CONFIG:}")
private String firebaseConfigJson;

@PostConstruct
public void initialize() {
    try {
        InputStream serviceAccount;
        if (!firebaseConfigJson.isEmpty()) {
            // Read from environment variable
            serviceAccount = new ByteArrayInputStream(
                firebaseConfigJson.getBytes(StandardCharsets.UTF_8)
            );
        } else {
            // Fallback to file
            serviceAccount = getClass().getClassLoader()
                .getResourceAsStream("firebase-service-account.json");
        }
        // ... rest of initialization
    } catch (IOException e) {
        throw new RuntimeException("Failed to initialize Firebase", e);
    }
}
```

#### Step 5: Deploy

1. Click "Create Web Service"
2. Wait for build to complete
3. Note the service URL (e.g., `https://etech-backend.onrender.com`)

### Option 2: Railway

#### Step 1: Deploy on Railway

1. Go to [Railway](https://railway.app)
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Select your repository
5. Railway will auto-detect Java/Maven

#### Step 2: Configure Build

Railway should auto-detect, but verify:
- **Root Directory**: `backend`
- **Build Command**: `mvn clean install -DskipTests`
- **Start Command**: `java -jar target/electricals-backend-1.0.0.jar`

#### Step 3: Add Environment Variables

In Railway dashboard:
1. Go to "Variables" tab
2. Add `FIREBASE_CONFIG` with your service account JSON content

#### Step 4: Deploy

1. Railway will automatically deploy
2. Get your service URL from the dashboard

### Option 3: Heroku

#### Step 1: Install Heroku CLI

```bash
# Download from https://devcenter.heroku.com/articles/heroku-cli
```

#### Step 2: Create Heroku App

```bash
cd backend
heroku create etech-backend
```

#### Step 3: Set Environment Variables

```bash
heroku config:set FIREBASE_CONFIG="$(cat ../firebase-service-account.json)"
```

#### Step 4: Deploy

```bash
git push heroku main
```

## Frontend Deployment

### Netlify Deployment

#### Step 1: Build Locally (Optional)

```bash
cd frontend
npm install
npm run build
```

#### Step 2: Deploy via Netlify Dashboard

1. Go to [Netlify](https://app.netlify.com)
2. Click "Add new site" > "Import an existing project"
3. Connect to GitHub
4. Select your repository
5. Configure:
   - **Base directory**: `frontend`
   - **Build command**: `npm run build`
   - **Publish directory**: `frontend/build`

#### Step 3: Set Environment Variables

In Netlify dashboard:
1. Go to "Site settings" > "Environment variables"
2. Add:
   - `REACT_APP_API_URL`: Your backend URL (e.g., `https://etech-backend.onrender.com/api`)

#### Step 4: Update Firebase Config

1. Edit `frontend/src/config/firebase.js`
2. Replace placeholder values with your Firebase web app config:

```javascript
const firebaseConfig = {
  apiKey: "your-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "your-app-id"
};
```

#### Step 5: Deploy

1. Click "Deploy site"
2. Wait for build to complete
3. Your site will be available at `https://your-site.netlify.app`

### Alternative: Netlify CLI

```bash
cd frontend
npm install -g netlify-cli
netlify login
netlify init
netlify deploy --prod
```

## Environment Configuration

### Backend Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `FIREBASE_CONFIG` | Firebase service account JSON | `{"type":"service_account",...}` |
| `SERVER_PORT` | Server port (optional) | `8080` |

### Frontend Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `REACT_APP_API_URL` | Backend API URL | `https://etech-backend.onrender.com/api` |

## Post-Deployment

### 1. Test Backend

```bash
curl https://your-backend-url.com/api/dashboard/stats
```

### 2. Test Frontend

1. Visit your Netlify URL
2. Try logging in
3. Test creating a customer/item
4. Verify API calls work

### 3. Update CORS Settings

In `backend/src/main/resources/application.properties`:

```properties
spring.web.cors.allowed-origins=https://your-app.netlify.app,http://localhost:3000
```

Redeploy backend after updating.

### 4. Create First User

1. Go to Firebase Console > Authentication
2. Click "Add user"
3. Enter email and password
4. Use these credentials to login in the app

## Troubleshooting

### Backend Issues

**Problem**: Firebase connection error
- **Solution**: Verify `FIREBASE_CONFIG` environment variable is set correctly

**Problem**: CORS errors
- **Solution**: Update `allowed-origins` in `application.properties` with your frontend URL

**Problem**: Port binding error
- **Solution**: Set `SERVER_PORT` environment variable or let platform assign port

### Frontend Issues

**Problem**: API calls failing
- **Solution**: Check `REACT_APP_API_URL` is set correctly in Netlify

**Problem**: Firebase auth not working
- **Solution**: Verify Firebase config in `firebase.js` matches your project

**Problem**: Build fails
- **Solution**: Check build logs in Netlify, ensure all dependencies are in `package.json`

## Security Checklist

- [ ] Firebase service account JSON is not committed to Git
- [ ] Environment variables are set in deployment platform
- [ ] CORS is configured with specific origins
- [ ] Firebase Authentication is enabled
- [ ] Firestore security rules are configured (if needed)
- [ ] HTTPS is enabled (automatic on Netlify/Render)

## Monitoring

### Backend Monitoring

- Render: Built-in metrics dashboard
- Railway: Built-in metrics
- Heroku: Use Heroku Metrics

### Frontend Monitoring

- Netlify: Built-in analytics
- Consider adding: Google Analytics, Sentry

## Cost Estimation

### Free Tier Limits

- **Render**: 750 hours/month (free tier)
- **Railway**: $5 credit/month
- **Netlify**: 100GB bandwidth/month
- **Firebase**: Generous free tier

### Scaling Considerations

- Monitor usage
- Upgrade plans as needed
- Consider caching strategies
- Optimize database queries

## Next Steps

1. Set up custom domain (optional)
2. Configure SSL certificates (automatic on most platforms)
3. Set up CI/CD pipelines
4. Add monitoring and logging
5. Implement backup strategies


