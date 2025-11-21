# E-Tech Electricals - Full-Stack Management System

A comprehensive full-stack web application for managing invoices, quotations, inventory, and financial tracking for E-Tech Electricals.

## 🏗️ Architecture

- **Backend**: Spring Boot (Java) with Firebase Firestore
- **Frontend**: React.js with modern UI
- **Database**: Firebase Firestore (NoSQL)
- **Authentication**: Firebase Authentication
- **Deployment**: 
  - Backend: Render/Railway/Heroku
  - Frontend: Netlify

## 📁 Project Structure

```
E tech/
├── backend/                 # Spring Boot backend
│   ├── src/
│   │   └── main/
│   │       ├── java/com/etech/
│   │       │   ├── config/      # Configuration classes
│   │       │   ├── controller/ # REST controllers
│   │       │   ├── model/       # Data models
│   │       │   ├── service/     # Business logic
│   │       │   └── security/    # Security configuration
│   │       └── resources/
│   │           └── application.properties
│   ├── pom.xml
│   └── Dockerfile
│
└── frontend/               # React.js frontend
    ├── src/
    │   ├── components/     # React components
    │   ├── contexts/       # React contexts
    │   └── config/         # Configuration files
    ├── package.json
    └── netlify.toml
```

## 🚀 Quick Start

### Prerequisites

- Java 17+
- Maven 3.6+
- Node.js 16+
- Firebase account
- Git

### 1. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Firestore Database** (Start in production mode)
4. Enable **Authentication** (Email/Password provider)
5. Go to Project Settings > Service Accounts
6. Click "Generate new private key"
7. Save the JSON file as `backend/src/main/resources/firebase-service-account.json`

### 2. Backend Setup

```bash
cd backend

# Build the project
mvn clean install

# Run the application
mvn spring-boot:run
```

The backend will run on `http://localhost:8080`

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Configure Firebase
# Edit src/config/firebase.js with your Firebase config

# Create .env file
echo "REACT_APP_API_URL=http://localhost:8080/api" > .env

# Run the application
npm start
```

The frontend will run on `http://localhost:3000`

## 📚 API Documentation

### Base URL
```
http://localhost:8080/api
```

### Endpoints

#### Customers
- `GET /customers` - Get all customers
- `GET /customers/{id}` - Get customer by ID
- `POST /customers` - Create customer
- `PUT /customers/{id}` - Update customer
- `DELETE /customers/{id}` - Delete customer

#### Items
- `GET /items` - Get all items
- `GET /items/{id}` - Get item by ID
- `POST /items` - Create item
- `PUT /items/{id}` - Update item
- `DELETE /items/{id}` - Delete item
- `PATCH /items/{id}/stock` - Update stock quantity

#### Invoices
- `GET /invoices` - Get all invoices
- `GET /invoices/{id}` - Get invoice by ID
- `POST /invoices` - Create invoice
- `PUT /invoices/{id}` - Update invoice
- `DELETE /invoices/{id}` - Delete invoice
- `POST /invoices/{id}/mark-paid` - Mark invoice as paid

#### Quotations
- `GET /quotations` - Get all quotations
- `GET /quotations/{id}` - Get quotation by ID
- `POST /quotations` - Create quotation
- `PUT /quotations/{id}` - Update quotation
- `DELETE /quotations/{id}` - Delete quotation

#### Transactions
- `GET /transactions` - Get all transactions
- `POST /transactions` - Create transaction
- `GET /transactions/reports?year=2024&month=1` - Get financial report

#### Dashboard
- `GET /dashboard/stats` - Get dashboard statistics

## 🔐 Authentication

The application uses Firebase Authentication. Users need to:

1. Sign up/login through the frontend
2. Firebase ID tokens are automatically sent with API requests
3. Backend verifies tokens using Firebase Admin SDK

## 🚢 Deployment

### Backend Deployment (Render)

1. Push code to GitHub
2. Go to [Render](https://render.com)
3. Create new Web Service
4. Connect your repository
5. Settings:
   - Build Command: `cd backend && mvn clean install`
   - Start Command: `cd backend && java -jar target/electricals-backend-1.0.0.jar`
   - Environment Variables:
     - Add `FIREBASE_CONFIG` as a secret (paste your service account JSON)

### Backend Deployment (Railway)

1. Push code to GitHub
2. Go to [Railway](https://railway.app)
3. New Project > Deploy from GitHub
4. Select your repository
5. Add environment variable:
   - `FIREBASE_CONFIG` (your service account JSON)

### Frontend Deployment (Netlify)

1. Build the frontend:
   ```bash
   cd frontend
   npm run build
   ```

2. Deploy to Netlify:
   - Option 1: Drag and drop `build` folder
   - Option 2: Connect Git repository
   - Option 3: Use CLI:
     ```bash
     npm install -g netlify-cli
     netlify deploy --prod --dir=build
     ```

3. Set environment variable:
   - `REACT_APP_API_URL`: Your deployed backend URL

## 🔄 Spring Boot + Firebase Integration

### Connection Setup

The backend uses Firebase Admin SDK to connect to Firestore:

```java
@Configuration
public class FirebaseConfig {
    @PostConstruct
    public void initialize() {
        // Loads service account JSON
        // Initializes Firebase App
        // Provides Firestore bean
    }
}
```

### CRUD Operations Example

```java
// Create
var docRef = firestore.collection("customers").document();
docRef.set(customer).get();

// Read
var doc = firestore.collection("customers").document(id).get().get();
Customer customer = doc.toObject(Customer.class);

// Update
firestore.collection("customers").document(id).set(customer).get();

// Delete
firestore.collection("customers").document(id).delete().get();
```

## 📱 Future: Flutter Android App

The architecture is designed to support a Flutter mobile app:

1. **Same Firebase Backend**: Flutter can use the same Firestore database
2. **REST API**: Flutter can call the same Spring Boot APIs
3. **Firebase Auth**: Flutter can use Firebase Auth SDK
4. **Shared Models**: Data models are consistent across platforms

### Flutter Integration Steps

1. Add Firebase to Flutter project
2. Use `http` or `dio` package for API calls
3. Use `firebase_auth` for authentication
4. Use `cloud_firestore` for direct database access (optional)
5. Reuse the same API endpoints

## 🛠️ Best Practices

### Firebase + Spring Boot

1. **Service Account**: Never commit service account JSON to Git
2. **Connection Pooling**: Firebase handles connections automatically
3. **Error Handling**: Always handle ExecutionException and InterruptedException
4. **Data Modeling**: Use Firestore's document-based structure efficiently

### Security

1. **CORS**: Configure allowed origins in `application.properties`
2. **Authentication**: All endpoints (except `/api/auth/**`) require Firebase token
3. **Validation**: Validate all input data
4. **Environment Variables**: Use environment variables for sensitive data

### Scalability

1. **Modular Design**: Services are separated by domain
2. **Stateless API**: Backend is stateless, can scale horizontally
3. **Firestore**: Automatically scales with usage
4. **Caching**: Consider adding Redis for frequently accessed data

## 📝 Adding New Features

### Adding a New Entity

1. Create model class in `backend/src/main/java/com/etech/model/`
2. Create service class in `backend/src/main/java/com/etech/service/`
3. Create controller in `backend/src/main/java/com/etech/controller/`
4. Create React component in `frontend/src/components/`
5. Add route in `frontend/src/App.js`

### Example: Adding "Suppliers"

```java
// Model
public class Supplier { ... }

// Service
@Service
public class SupplierService { ... }

// Controller
@RestController
@RequestMapping("/api/suppliers")
public class SupplierController { ... }
```

## 🐛 Troubleshooting

### Backend Issues

- **Firebase connection error**: Check service account JSON path
- **CORS errors**: Update allowed origins in `application.properties`
- **Port already in use**: Change port in `application.properties`

### Frontend Issues

- **API connection error**: Check `REACT_APP_API_URL` in `.env`
- **Firebase auth error**: Verify Firebase config in `src/config/firebase.js`
- **Build errors**: Clear `node_modules` and reinstall

## 📄 License

This project is proprietary software for E-Tech Electricals.

## 👥 Support

For issues or questions, please contact the development team.


