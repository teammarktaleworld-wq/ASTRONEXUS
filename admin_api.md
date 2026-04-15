
# AstroNexus Admin API Documentation (Backend + Flutter Integration)

**Base URL:**
```
https://astro-nexus-new-6-46mo.onrender.com/api
```

---

## Authentication
Most admin endpoints require authentication (JWT token) and admin privileges.

---

## Endpoints

### 1. Admin Authentication

#### Create Admin
- **POST** `/admin/auth/create`
- **Payload:**
```json
{
  "username": "string",
  "password": "string",
  "setupKey": "string"
}
```
- **Description:** Create a new admin (requires setup key).

#### Admin Login
- **POST** `/admin/auth/login`
- **Payload:**
```json
{
  "username": "string",
  "password": "string"
}
```
- **Description:** Login as admin.

#### Get All Admins
- **GET** `/admin/auth/all`
- **Headers:** `Authorization: Bearer <token>`

#### Update Admin Password
- **PUT** `/admin/auth/update-password`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "oldPassword": "string",
  "newPassword": "string"
}
```

#### Admin Logout
- **POST** `/admin/auth/logout`
- **Headers:** `Authorization: Bearer <token>`

---

### 2. User Management

#### Get All Users
- **GET** `/admin/users/`
- **Headers:** `Authorization: Bearer <token>`

#### Create User (by Admin)
- **POST** `/admin/users/`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "password": "string",
  "role": "user|admin"
}
```

#### Block/Unblock User
- **PATCH** `/admin/users/:id/block`
- **Headers:** `Authorization: Bearer <token>`

#### Delete User
- **DELETE** `/admin/users/:id`
- **Headers:** `Authorization: Bearer <token>`

---

### 3. Product Management

#### Create Product
- **POST** `/admin/products/`
- **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
- **Payload:**
  - `images`: array of images (max 5)
  - Other product fields (name, price, etc.)

#### Get All Products
- **GET** `/admin/products/`
- **Headers:** `Authorization: Bearer <token>`

#### Get Product by ID
- **GET** `/admin/products/:id`
- **Headers:** `Authorization: Bearer <token>`

#### Update Product
- **PUT** `/admin/products/:id`
- **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
- **Payload:**
  - `images`: array of images (optional)
  - `removedImages`: array of image URLs to remove (optional)
  - Other product fields

#### Deactivate Product
- **PATCH** `/admin/products/:id/deactivate`
- **Headers:** `Authorization: Bearer <token>`

#### Delete Product (Permanent)
- **DELETE** `/admin/products/:id`
- **Headers:** `Authorization: Bearer <token>`

---

### 4. Category Management

#### Create Category
- **POST** `/admin/categories/`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "name": "string",
  "description": "string",
  "order": 0
}
```

#### Get All Categories
- **GET** `/admin/categories/`
- **Headers:** `Authorization: Bearer <token>`

#### Update Category
- **PUT** `/admin/categories/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "name": "string",
  "description": "string",
  "order": 0
}
```

#### Toggle Category Status
- **PATCH** `/admin/categories/:id/toggle`
- **Headers:** `Authorization: Bearer <token>`

#### Delete Category
- **DELETE** `/admin/categories/:id`
- **Headers:** `Authorization: Bearer <token>`

---

### 5. Order Management

#### Get All Orders
- **GET** `/admin/orders/all`
- **Headers:** `Authorization: Bearer <token>`

#### Update Order Status
- **PUT** `/admin/orders/:id/status`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "status": "string"
}
```

#### Delete Order
- **DELETE** `/admin/orders/:id`
- **Headers:** `Authorization: Bearer <token>`

#### Get Order Counts
- **GET** `/admin/orders/counts`
- **Headers:** `Authorization: Bearer <token>`

#### Get Orders by User
- **GET** `/admin/orders/user/:userId`
- **Headers:** `Authorization: Bearer <token>`

---

### 6. Discount Management

#### Create Discount
- **POST** `/admin/discounts/`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "code": "string",
  "percentage": number,
  "expiry": "ISO8601 date string"
}
```

#### Get All Discounts
- **GET** `/admin/discounts/`
- **Headers:** `Authorization: Bearer <token>`

#### Update Discount
- **PUT** `/admin/discounts/:discountId`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "percentage": number,
  "expiry": "ISO8601 date string"
}
```

#### Delete Discount
- **DELETE** `/admin/discounts/:discountId`
- **Headers:** `Authorization: Bearer <token>`

#### Apply Discount
- **POST** `/admin/discounts/apply`
- **Payload:**
```json
{
  "code": "string",
  "amount": number
}
```

---

### 7. Notification Management

#### Get All Notifications
- **GET** `/admin/notifications/`
- **Headers:** `Authorization: Bearer <token>`

#### Mark Notification as Read
- **PUT** `/admin/notifications/read/:notificationId`
- **Headers:** `Authorization: Bearer <token>`

#### Create Notification
- **POST** `/admin/notifications/`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "userId": "string", // optional if broadcast
  "type": "string",
  "title": "string",
  "message": "string",
  "broadcast": true // optional
}
```

---

### 8. CMS Management

#### Create CMS Entry
- **POST** `/admin/cms/`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "title": "string",
  "content": "string"
}
```

#### Get All CMS Entries
- **GET** `/admin/cms/`
- **Headers:** `Authorization: Bearer <token>`

#### Update CMS Entry
- **PUT** `/admin/cms/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Payload:**
```json
{
  "title": "string",
  "content": "string"
}
```

---

### 9. Dashboard


#### Get Dashboard Overview
- **GET** `/admin/dashboard/`
- **Headers:** `Authorization: Bearer <token>`
- **Response Example:**
```json
{
  "totals": {
    "totalUsers": 1234,
    "totalProducts": 56,
    "totalOrders": 789,
    "totalRevenue": 123456.78
  },
  "recentUsers": [
    { "_id": "...", "name": "John Doe", "email": "john@example.com", "createdAt": "2024-01-01T00:00:00.000Z" },
    // ... up to 5
  ],
  "recentOrders": [
    {
      "_id": "...",
      "user": { "_id": "...", "name": "John Doe", "email": "john@example.com" },
      "items": [
        { "product": { "_id": "...", "name": "Product A", "price": 100, "images": ["url1", "url2"] }, "quantity": 2, "price": 100 }
      ],
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
    // ... up to 5
  ],
  "mostPurchasedProduct": {
    "_id": "...",
    "name": "Product A",
    "images": ["url1", "url2"],
    "price": 100,
    "totalSold": 50
  },
  "topUser": {
    "_id": "...",
    "name": "Jane Smith",
    "email": "jane@example.com",
    "totalSpent": 5000
  },
  "admins": [
    { "_id": "...", "name": "Admin User", "email": "admin@example.com", "createdAt": "2024-01-01T00:00:00.000Z" }
    // ...
  ]
}
```
**Description:** Returns total counts, recent users, recent orders, most purchased product, top user, and admin list for dashboard analytics.

---

### 10. Feedback Management

#### Get All Feedbacks
- **GET** `/admin/feedback/`
- **Headers:** `Authorization: Bearer <token>`

#### Delete Feedback
- **DELETE** `/admin/feedback/:feedbackId`
- **Headers:** `Authorization: Bearer <token>`

---

### 11. Address Management

#### Get All Addresses
- **GET** `/admin/addresses/all`
- **Headers:** `Authorization: Bearer <token>`

#### Delete Address
- **DELETE** `/admin/addresses/:addressId`
- **Headers:** `Authorization: Bearer <token>`

---

### 12. Invoice Management

#### Generate Invoice
- **GET** `/admin/invoice/generate/:orderId`
- **Headers:** `Authorization: Bearer <token>`

#### Download Invoice
- **GET** `/admin/invoice/download/:orderId`
- **Headers:** `Authorization: Bearer <token>`
- **Accept:** `application/pdf`

---

## Notes
- All endpoints are prefixed with `/admin/`.
- All requests and responses are in JSON unless otherwise specified.
- For file uploads, use `multipart/form-data`.
- All endpoints requiring authentication expect a JWT token in the `Authorization` header.
- Endpoints and payloads are deduplicated and unified for both backend and Flutter integration.

---

**This documentation is intended for building a Next.js admin panel and Flutter admin integration for AstroNexus.**
