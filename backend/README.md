# E-Tech Electricals Backend

Spring Boot backend API for E-Tech Electricals management system.

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- Firebase project with Firestore enabled
- Firebase service account JSON file

## Setup

1. **Firebase Setup:**
   - Go to Firebase Console (https://console.firebase.google.com/)
   - Create a new project or use existing
   - Enable Firestore Database
   - Go to Project Settings > Service Accounts
   - Generate new private key
   - Save the JSON file as `firebase-service-account.json` in `src/main/resources/`

2. **Build the project:**
   ```bash
   mvn clean install
   ```

3. **Run the application:**
   ```bash
   mvn spring-boot:run
   ```

The API will be available at `http://localhost:8080`

## API Endpoints

### Customers
- `POST /api/customers` - Create customer
- `GET /api/customers` - Get all customers
- `GET /api/customers/{id}` - Get customer by ID
- `PUT /api/customers/{id}` - Update customer
- `DELETE /api/customers/{id}` - Delete customer

### Items
- `POST /api/items` - Create item
- `GET /api/items` - Get all items
- `GET /api/items/{id}` - Get item by ID
- `PUT /api/items/{id}` - Update item
- `DELETE /api/items/{id}` - Delete item
- `PATCH /api/items/{id}/stock` - Update stock quantity

### Invoices
- `POST /api/invoices` - Create invoice
- `GET /api/invoices` - Get all invoices
- `GET /api/invoices/{id}` - Get invoice by ID
- `PUT /api/invoices/{id}` - Update invoice
- `DELETE /api/invoices/{id}` - Delete invoice
- `POST /api/invoices/{id}/mark-paid` - Mark invoice as paid

### Quotations
- `POST /api/quotations` - Create quotation
- `GET /api/quotations` - Get all quotations
- `GET /api/quotations/{id}` - Get quotation by ID
- `PUT /api/quotations/{id}` - Update quotation
- `DELETE /api/quotations/{id}` - Delete quotation

### Transactions
- `POST /api/transactions` - Create transaction
- `GET /api/transactions` - Get all transactions
- `GET /api/transactions/reports?year=2024&month=1` - Get financial report

### Dashboard
- `GET /api/dashboard/stats` - Get dashboard statistics

## Deployment

### Using Docker

1. Build the Docker image:
   ```bash
   docker build -t etech-backend .
   ```

2. Run the container:
   ```bash
   docker run -p 8080:8080 -v /path/to/firebase-service-account.json:/app/firebase-service-account.json etech-backend
   ```

### Using Render/Railway

1. Push code to GitHub
2. Connect repository to Render/Railway
3. Set environment variables if needed
4. Deploy

Note: Make sure to add `firebase-service-account.json` as an environment variable or secret in your deployment platform.


