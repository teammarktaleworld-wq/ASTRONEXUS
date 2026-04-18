# ASTRO_NEXUS API Documentation
## Admin Endpoints

### 1. Admin Authentication
**Endpoint**: `POST /api/admin/auth/login`
**Request Body**:
```json
{
  "email": "admin@example.com",
  "password": "adminpassword"
}
```
**Response**:
```json
{
  "message": "Login successful",
  "token": "jwt_token"
}
```

### 2. Create Admin
**Endpoint**: `POST /api/admin/auth/create`
**Request Body**:
```json
{
  "email": "admin@example.com",
  "password": "adminpassword",
  "setupKey": "setup_key"
}
```
**Response**:
```json
{
  "message": "Admin created successfully",
  "admin": {
    "id": "admin_id",
    "email": "admin@example.com"
  }
}
```

### 3. Get All Admins
**Endpoint**: `GET /api/admin/auth/all`
**Authentication**: Required
**Response**:
```json
[
  {
    "id": "admin_id",
    "email": "admin@example.com"
  }
]
```

### 4. Update Admin Password
**Endpoint**: `PUT /api/admin/auth/update-password`
**Authentication**: Required
**Request Body**:
```json
{
  "oldPassword": "old_password",
  "newPassword": "new_password"
}
```
**Response**:
```json
{
  "message": "Password updated successfully"
}
```

### 5. Admin Logout
**Endpoint**: `POST /api/admin/auth/logout`
**Authentication**: Required
**Response**:
```json
{
  "message": "Logged out successfully"
}
```

### 6. Product Management
**Endpoint**: `POST /api/admin/products`
**Authentication**: Required
**Request Body**:
```json
{
  "name": "Product Name",
  "price": 100,
  "category": "category_id",
  "astrologyType": "gemstone",
  "stock": 10,
  "description": "Product description",
  "isActive": true,
  "deliveryType": "physical"
}
```
**Response**:
```json
{
  "success": true,
  "product": {
    "id": "product_id",
    "name": "Product Name",
    "price": 100,
    "category": "category_id",
    "astrologyType": "gemstone",
    "stock": 10,
    "description": "Product description",
    "isActive": true,
    "deliveryType": "physical"
  }
}
```

### 7. Get All Products
**Endpoint**: `GET /api/admin/products`
**Authentication**: Required
**Response**:
```json
[
  {
    "id": "product_id",
    "name": "Product Name",
    "price": 100,
    "category": "category_id",
    "astrologyType": "gemstone",
    "stock": 10,
    "description": "Product description",
    "isActive": true,
    "deliveryType": "physical"
  }
]
```

### 8. Update Product
**Endpoint**: `PUT /api/admin/products/:id`
**Authentication**: Required
**Request Body**:
```json
{
  "name": "Updated Product Name",
  "price": 120,
  "stock": 15,
  "description": "Updated description"
}
```
**Response**:
```json
{
  "success": true,
  "product": {
    "id": "product_id",
    "name": "Updated Product Name",
    "price": 120,
    "stock": 15,
    "description": "Updated description"
  }
}
```

### 9. Deactivate Product
**Endpoint**: `PATCH /api/admin/products/:id/deactivate`
**Authentication**: Required
**Response**:
```json
{
  "success": true,
  "message": "Product deactivated"
}
```

### 10. Delete Product
**Endpoint**: `DELETE /api/admin/products/:id`
**Authentication**: Required
**Response**:
```json
{
  "success": true,
  "message": "Product deleted"
}
```

### 11. User Management
**Endpoint**: `GET /api/admin/users`
**Authentication**: Required
**Response**:
```json
[
  {
    "id": "user_id",
    "name": "User Name",
    "email": "user@example.com",
    "phone": "+1234567890",
    "role": "user"
  }
]
```

**Endpoint**: `POST /api/admin/users`
**Authentication**: Required
**Request Body**:
```json
{
  "name": "User Name",
  "email": "user@example.com",
  "phone": "+1234567890",
  "password": "userpassword",
  "role": "user"
}
```
**Response**:
```json
{
  "id": "user_id",
  "name": "User Name",
  "email": "user@example.com",
  "phone": "+1234567890",
  "role": "user"
}
```

**Endpoint**: `PATCH /api/admin/users/:id/block`
**Authentication**: Required
**Response**:
```json
{
  "id": "user_id",
  "blocked": true
}
```

**Endpoint**: `DELETE /api/admin/users/:id`
**Authentication**: Required
**Response**:
```json
{
  "id": "user_id",
  "deleted": true
}
```

### 12. Order Management
**Endpoint**: `GET /api/admin/orders/all`
**Authentication**: Required
**Response**:
```json
{
  "success": true,
  "count": 2,
  "orders": [
    {
      "id": "order_id",
      "user": {
        "id": "user_id",
        "name": "User Name",
        "email": "user@example.com"
      },
      "items": [
        {
          "product": {
            "id": "product_id",
            "name": "Product Name",
            "price": 100,
            "images": ["image_url"]
          },
          "quantity": 2,
          "price": 100
        }
      ],
      "status": "Placed",
      "totalAmount": 200,
      "createdAt": "2026-02-26T12:00:00Z"
    }
  ]
}
```

**Endpoint**: `PUT /api/admin/orders/:id/status`
**Authentication**: Required
**Request Body**:
```json
{
  "status": "Delivered"
}
```
**Response**:
```json
{
  "success": true,
  "order": {
    "id": "order_id",
    "status": "Delivered"
  }
}
```

**Endpoint**: `DELETE /api/admin/orders/:id`
**Authentication**: Required
**Response**:
```json
{
  "success": true,
  "message": "Order deleted"
}
```

### 13. Dashboard Overview
**Endpoint**: `GET /api/admin/dashboard`
**Authentication**: Required
**Response**:
```json
{
  "totalUsers": 100,
  "totalProducts": 50,
  "totalOrders": 200,
  "recentUsers": [
    { "name": "User Name", "email": "user@example.com", "createdAt": "2026-02-26T12:00:00Z" }
  ],
  "recentOrders": [
    { "id": "order_id", "user": { "name": "User Name" }, "items": [ ... ] }
  ],
  "totalRevenue": 50000,
  "mostPurchasedProduct": { "id": "product_id", "totalSold": 100 }
}
```

### 14. CMS Management
**Endpoint**: `POST /api/admin/cms`
**Authentication**: Required
**Request Body**:
```json
{
  "type": "banner",
  "title": "Welcome Banner",
  "content": "Welcome to our site!",
  "image": "banner_url",
  "isActive": true
}
```
**Response**:
```json
{
  "id": "cms_id",
  "type": "banner",
  "title": "Welcome Banner",
  "content": "Welcome to our site!",
  "image": "banner_url",
  "isActive": true
}
```

**Endpoint**: `GET /api/admin/cms`
**Authentication**: Required
**Response**:
```json
[
  {
    "id": "cms_id",
    "type": "banner",
    "title": "Welcome Banner",
    "content": "Welcome to our site!",
    "image": "banner_url",
    "isActive": true
  }
]
```

**Endpoint**: `PUT /api/admin/cms/:id`
**Authentication**: Required
**Request Body**:
```json
{
  "title": "Updated Banner",
  "content": "Updated content"
}
```
**Response**:
```json
{
  "id": "cms_id",
  "title": "Updated Banner",
  "content": "Updated content"
}
```

### 15. Category Management
**Endpoint**: `POST /api/admin/categories`
**Authentication**: Required
**Request Body**:
```json
{
  "name": "Gemstones",
  "description": "All gemstone products"
}
```
**Response**:
```json
{
  "id": "category_id",
  "name": "Gemstones",
  "description": "All gemstone products",
  "slug": "gemstones",
  "isActive": true
}
```

**Endpoint**: `GET /api/admin/categories`
**Authentication**: Required
**Response**:
```json
[
  {
    "id": "category_id",
    "name": "Gemstones",
    "description": "All gemstone products",
    "slug": "gemstones",
    "isActive": true
  }
]
```

**Endpoint**: `PUT /api/admin/categories/:id`
**Authentication**: Required
**Request Body**:
```json
{
  "name": "Updated Category",
  "description": "Updated description"
}
```
**Response**:
```json
{
  "id": "category_id",
  "name": "Updated Category",
  "description": "Updated description"
}
```

**Endpoint**: `PATCH /api/admin/categories/:id/toggle`
**Authentication**: Required
**Response**:
```json
{
  "id": "category_id",
  "isActive": false
}
```

**Endpoint**: `DELETE /api/admin/categories/:id`
**Authentication**: Required
**Response**:
```json
{
  "id": "category_id",
  "deleted": true
}
```

### 16. Discount Management
**Endpoint**: `POST /api/discount`
**Authentication**: Required
**Request Body**:
```json
{
  "code": "NEWYEAR",
  "percentage": 10,
  "expiry": "2026-12-31T23:59:59Z"
}
```
**Response**:
```json
{
  "id": "discount_id",
  "code": "NEWYEAR",
  "percentage": 10,
  "expiry": "2026-12-31T23:59:59Z",
  "active": true
}
```

**Endpoint**: `GET /api/discount`
**Response**:
```json
[
  {
    "id": "discount_id",
    "code": "NEWYEAR",
    "percentage": 10,
    "expiry": "2026-12-31T23:59:59Z",
    "active": true
  }
]
```

**Endpoint**: `PUT /api/discount/:discountId`
**Authentication**: Required
**Request Body**:
```json
{
  "percentage": 15
}
```
**Response**:
```json
{
  "id": "discount_id",
  "percentage": 15
}
```

**Endpoint**: `DELETE /api/discount/:discountId`
**Authentication**: Required
**Response**:
```json
{
  "id": "discount_id",
  "deleted": true
}
```

### 17. Coupon Management
**Endpoint**: `POST /api/coupon`
**Authentication**: Required
**Request Body**:
```json
{
  "code": "WELCOME10",
  "type": "percentage",
  "value": 10,
  "expiry": "2026-12-31T23:59:59Z"
}
```
**Response**:
```json
{
  "id": "coupon_id",
  "code": "WELCOME10",
  "type": "percentage",
  "value": 10,
  "expiry": "2026-12-31T23:59:59Z",
  "active": true
}
```

**Endpoint**: `POST /api/coupon/apply`
**Authentication**: Required
**Request Body**:
```json
{
  "code": "WELCOME10",
  "orderAmount": 200
}
```
**Response**:
```json
{
  "success": true,
  "discount": 20
}
```
 
## Base URL
```
http://localhost:8001
```
 
## Authentication
This API uses JWT (JSON Web Token) for authentication. Include the token in requests using either:
- **Header**: `Authorization: Bearer <token>`
- **Cookie**: `token=<token>`
 
---
 
## Table of Contents
1. [Authentication Endpoints](#authentication-endpoints)
2. [User Endpoints](#user-endpoints)
3. [Order Endpoints](#order-endpoints)
4. [Shipping Endpoints](#shipping-endpoints)
5. [Prediction Endpoints](#prediction-endpoints)
6. [Horoscope Endpoints](#horoscope-endpoints)
7. [Birth Chart Endpoints](#birth-chart-endpoints)
8. [URL Management Endpoints](#url-management-endpoints)
9. [Utility Endpoints](#utility-endpoints)
10. [Admin Endpoints](#admin-endpoints)
11. [Error Responses](#error-responses)
 
---

## Base URL
```
http://localhost:8001
```

## Authentication
This API uses JWT (JSON Web Token) for authentication. Include the token in requests using either:
- **Header**: `Authorization: Bearer <token>`
- **Cookie**: `token=<token>`

---

## Table of Contents
1. [Authentication Endpoints](#authentication-endpoints)
2. [URL Management Endpoints](#url-management-endpoints)
3. [Utility Endpoints](#utility-endpoints)
4. [Error Responses](#error-responses)

---

## Authentication Endpoints
 
## User Endpoints

### 1. Basic Signup
**Endpoint**: `POST /user/signup/basic`
**Request Body**:
```json
{
  "name": "John Doe",
  "phone": "+1234567890",
  "email": "john@example.com",
  "password": "password123",
  "confirmPassword": "password123"
}
```
**Response**:
```json
{
  "success": true,
  "token": "jwt_token",
  "refreshToken": "refresh_token",
  "user": {
    "id": "user_id",
    "name": "John Doe",
    "phone": "+1234567890",
    "email": "john@example.com",
    "sessionId": "session_id"
  }
}
```

### 2. Astrology Signup
**Endpoint**: `POST /user/signup/astrology`
**Request Body**:
```json
{
  "name": "John Doe",
  "phone": "+1234567890",
  "email": "john@example.com",
  "password": "password123",
  "confirmPassword": "password123",
  "dateOfBirth": "1990-01-01",
  "timeOfBirth": "14:30",
  "placeOfBirth": "Mumbai, India",
  "tempChartId": "chart_id"
}
```
**Response**:
```json
{
  "success": true,
  "token": "jwt_token",
  "refreshToken": "refresh_token",
  "user": {
    "id": "user_id",
    "name": "John Doe",
    "sessionId": "session_id",
    "astrologyProfile": {
      "dateOfBirth": "1990-01-01",
      "timeOfBirth": "14:30",
      "placeOfBirth": "Mumbai, India"
    },
    "birthChart": {
      "chartImage": "image_url",
      "chartData": {},
      "rashi": "Aries",
      "isTemporary": false
    }
  }
}
```

### 3. Login (Email)
**Endpoint**: `POST /user/login`
**Request Body**:
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```
**Response**:
```json
{
  "success": true,
  "token": "jwt_token",
  "refreshToken": "refresh_token",
  "user": {
    "id": "user_id",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "role": "user",
    "isBlocked": false,
    "lastLoginAt": "2026-02-26T12:00:00Z",
    "sessionId": "session_id",
    "astrologyProfile": {
      "dateOfBirth": "1990-01-01",
      "timeOfBirth": "14:30",
      "placeOfBirth": "Mumbai, India"
    },
    "charts": [
      {
        "id": "chart_id",
        "chartImage": "image_url",
        "chartData": {},
        "rashi": "Aries",
        "createdAt": "2026-02-26T12:00:00Z"
      }
    ],
    "chartsCount": 1
  }
}
```

### 4. Login (Phone)
**Endpoint**: `POST /user/login/phone`
**Request Body**:
```json
{
  "phone": "+1234567890",
  "password": "password123"
}
```
**Response**:
```json
{
  "success": true,
  "token": "jwt_token",
  "refreshToken": "refresh_token",
  "user": {
    "id": "user_id",
    "name": "John Doe",
    "phone": "+1234567890",
    "email": "john@example.com",
    "role": "user",
    "isBlocked": false,
    "lastLoginAt": "2026-02-26T12:00:00Z",
    "sessionId": "session_id",
    "astrologyProfile": {
      "dateOfBirth": "1990-01-01",
      "timeOfBirth": "14:30",
      "placeOfBirth": "Mumbai, India"
    },
    "charts": [
      {
        "id": "chart_id",
        "chartImage": "image_url",
        "chartData": {},
        "rashi": "Aries",
        "createdAt": "2026-02-26T12:00:00Z"
      }
    ],
    "chartsCount": 1
  }
}
```

### 5. Get My Profile
**Endpoint**: `GET /user/profile`
**Authentication**: Required
**Response**:
```json
{
  "success": true,
  "user": {
    "id": "user_id",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "sessionId": "session_id",
    "profileImage": {
      "publicId": "profile_id",
      "url": "profile_url"
    },
    "astrologyProfile": {
      "dateOfBirth": "1990-01-01",
      "timeOfBirth": "14:30",
      "placeOfBirth": "Mumbai, India"
    },
    "charts": [
      {
        "id": "chart_id",
        "chartImage": "image_url",
        "chartData": {},
        "rashi": "Aries",
        "createdAt": "2026-02-26T12:00:00Z"
      }
    ],
    "chartsCount": 1
  }
}
```

### 6. Update My Profile
**Endpoint**: `PUT /user/profile`
**Authentication**: Required
**Request Body**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "astrologyProfile": {
    "dateOfBirth": "1990-01-01",
    "timeOfBirth": "14:30",
    "placeOfBirth": "Mumbai, India"
  }
}
```
**Response**:
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "user": {
    "id": "user_id",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "astrologyProfile": {
      "dateOfBirth": "1990-01-01",
      "timeOfBirth": "14:30",
      "placeOfBirth": "Mumbai, India"
    },
    "profileImage": {
      "publicId": "profile_id",
      "url": "profile_url"
    },
    "sessionId": "session_id"
  }
}
```

### 7. Change Password
**Endpoint**: `POST /user/change-password`
**Authentication**: Required
**Request Body**:
```json
{
  "oldPassword": "old_password",
  "newPassword": "new_password",
  "confirmPassword": "new_password"
}
```
**Response**:
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

### 8. Upload Profile Image
**Endpoint**: `POST /user/upload-profile-image`
**Authentication**: Required
**Request**: Multipart/form-data (image file)
**Response**:
```json
{
  "success": true,
  "profileImage": {
    "url": "profile_url",
    "publicId": "profile_id"
  }
}
```

### 9. Logout
**Endpoint**: `POST /user/logout`
**Authentication**: Required
**Response**:
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### 10. Refresh Token
**Endpoint**: `POST /user/refresh-token`
**Request Body**:
```json
{
  "refreshToken": "refresh_token"
}
```
**Response**:
```json
{
  "success": true,
  "token": "jwt_token",
  "refreshToken": "refresh_token",
  "sessionId": "session_id"
}
```

---
 
## Order Endpoints
 
### 1. Place Order
**Endpoint**: `POST /users/order`
**Authentication**: Required
**Request Body**:
```json
{ "cart": [ ... ], "address": { ... }, "payment": { ... } }
```
**Response**:
```json
{ "success": true, "order": { ... } }
```
 
### 2. Get User Orders
**Endpoint**: `GET /users/order`
**Authentication**: Required
**Response**:
```json
{ "orders": [ ... ] }
```
 
---
 
## Shipping Endpoints
 
### 1. Get Shipping Methods
**Endpoint**: `GET /shipping`
**Response**:
```json
{ "methods": [ ... ] }
```
 
### 2. Create Shipping Method
**Endpoint**: `POST /shipping`
**Authentication**: Admin Required
**Request Body**:
```json
{ "method": "Express", "price": 100 }
```
**Response**:
```json
{ "success": true, "method": { ... } }
```
 
### 3. Update Shipping Method
**Endpoint**: `PUT /shipping/:shippingId`
**Authentication**: Admin Required
**Request Body**:
```json
{ "method": "Express", "price": 120 }
```
**Response**:
```json
{ "success": true }
```
 
### 4. Delete Shipping Method
**Endpoint**: `DELETE /shipping/:shippingId`
**Authentication**: Admin Required
**Response**:
```json
{ "success": true }
```
 
---
 
## Prediction Endpoints
 
### 1. Test Prediction Route
**Endpoint**: `GET /predictions/test`
**Response**: `Prediction route working!`
 
### 2. Generate Prediction
**Endpoint**: `POST /predictions/generate`
**Request Body**:
```json
{ "userData": { ... } }
```
**Response**:
```json
{ "prediction": { ... } }
```
 
---
 
## Horoscope Endpoints
 
### 1. Get Daily Horoscope
**Endpoint**: `GET /horoscopeRoute/daily`
**Response**:
```json
{ "horoscope": { ... } }
```
 
---
 
## Birth Chart Endpoints
 
### 1. Test Birth Chart Route
**Endpoint**: `GET /birthchart/test`
**Response**: `Birth chart route working!`
 
### 2. Generate Birth Chart
**Endpoint**: `POST /birthchart`
**Request Body**:
```json
{ "birthDetails": { ... } }
```
**Response**:
```json
{ "chart": { ... } }
```
 
---
 
## Admin Endpoints
 
(See admin route files for details: `/routes/admin/*`)
 
---

### 1. User Signup
Create a new user account.

**Endpoint**: `POST /user/signup`

**Request Body**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "password": "password123",
  "confirmPassword": "password123"
}
```

**Validation Rules**:
- `name`: Required, string
- `email`: Required, valid email format
- `phone`: Required, valid phone number
- `password`: Required, minimum 6 characters
- `confirmPassword`: Required, must match password

**Success Response** (201):
```json
{
  "success": true,
  "message": "User created successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "690e116c1e9e3f36f8790571",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

**Error Responses**:
- `400`: Missing fields, invalid email, password too short, email already registered
- `500`: Internal server error

---

### 2. User Login
Authenticate and receive a JWT token.

**Endpoint**: `POST /user/login`

**Request Body**:
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Success Response** (200):
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "690e116c1e9e3f36f8790571",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

**Error Responses**:
- `400`: Missing fields, invalid email format
- `401`: Invalid email or password
- `500`: Internal server error

---

### 3. User Logout
Logout and clear authentication token.

**Endpoint**: `POST /user/logout`

**Authentication**: Required

**Success Response** (200):
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

**Error Responses**:
- `401`: No token provided or invalid token

---

## URL Management Endpoints

### 4. Create Short URL
Generate a short URL for a given long URL.

**Endpoint**: `POST /api/url`

**Authentication**: Required

**Request Body**:
```json
{
  "url": "https://www.example.com/very/long/url",
  "customShortId": "mylink"  // Optional
}
```

**Validation Rules**:
- `url`: Required, valid URL with protocol (http:// or https://)
- `customShortId`: Optional, alphanumeric with hyphens/underscores only

**Success Response** (201):
```json
{
  "success": true,
  "message": "Short URL created successfully",
  "data": {
    "shortId": "46Ev-qvw",
    "originalUrl": "https://www.example.com/very/long/url",
    "shortUrl": "http://localhost:8001/url/46Ev-qvw",
    "createdAt": "2025-11-07T15:34:22.485Z"
  }
}
```

**Error Responses**:
- `400`: Missing URL, invalid URL format, custom ID already taken, invalid custom ID format
- `401`: Authentication required
- `500`: Internal server error

---

### 5. Get All URLs
Retrieve all short URLs created by the authenticated user.

**Endpoint**: `GET /api/url`

**Authentication**: Required

**Success Response** (200):
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "shortId": "46Ev-qvw",
      "originalUrl": "https://www.google.com",
      "shortUrl": "http://localhost:8001/url/46Ev-qvw",
      "clicks": 5,
      "createdAt": "2025-11-07T15:34:22.485Z"
    },
    {
      "shortId": "abc123",
      "originalUrl": "https://www.example.com",
      "shortUrl": "http://localhost:8001/url/abc123",
      "clicks": 12,
      "createdAt": "2025-11-06T10:20:15.123Z"
    }
  ]
}
```

**Error Responses**:
- `401`: Authentication required
- `500`: Internal server error

---

### 6. Get URL Analytics
Get detailed analytics for a specific short URL.

**Endpoint**: `GET /api/url/analytics/:shortId`

**Authentication**: Required

**URL Parameters**:
- `shortId`: The short URL identifier

**Success Response** (200):
```json
{
  "success": true,
  "data": {
    "shortId": "46Ev-qvw",
    "originalUrl": "https://www.google.com",
    "totalClicks": 3,
    "createdAt": "2025-11-07T15:34:22.485Z",
    "analytics": [
      {
        "timestamp": 1762529682554,
        "_id": "690e11921e9e3f36f8790576"
      },
      {
        "timestamp": 1762529700123,
        "_id": "690e11a41e9e3f36f8790577"
      }
    ]
  }
}
```

**Error Responses**:
- `401`: Authentication required
- `403`: Access denied (you don't own this URL)
- `404`: Short URL not found
- `500`: Internal server error

---

### 7. Delete Short URL
Delete a short URL.

**Endpoint**: `DELETE /api/url/:shortId`

**Authentication**: Required

**URL Parameters**:
- `shortId`: The short URL identifier

**Success Response** (200):
```json
{
  "success": true,
  "message": "Short URL deleted successfully"
}
```

**Error Responses**:
- `401`: Authentication required
- `403`: Access denied (you don't own this URL)
- `404`: Short URL not found
- `500`: Internal server error

---

### 8. Redirect to Original URL
Redirect to the original URL (public endpoint).

**Endpoint**: `GET /url/:shortId`

**Authentication**: Not required (public)

**URL Parameters**:
- `shortId`: The short URL identifier

**Success Response** (302):
- Redirects to the original URL
- Increments visit counter

**Error Responses**:
- `404`: Short URL not found
- `500`: Internal server error

---

## Utility Endpoints

### 9. Health Check
Check if the API is running.

**Endpoint**: `GET /health`

**Authentication**: Not required

**Success Response** (200):
```json
{
  "status": "ok",
  "timestamp": "2025-11-07T15:31:22.249Z"
}
```

---

## Error Responses

All error responses follow this format:

```json
{
  "error": "Error message describing what went wrong"
}
```

### Common HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 302 | Redirect |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (authentication required) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 429 | Too Many Requests (rate limit exceeded) |
| 500 | Internal Server Error |

---

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **General API endpoints**: 100 requests per 15 minutes per IP
- **Authentication endpoints** (`/user/login`, `/user/signup`): 5 requests per 15 minutes per IP

When rate limit is exceeded:
```json
{
  "error": "Too many requests, please try again later."
}
```

---

## Example Usage

### Using cURL

#### 1. Signup
```bash
curl -X POST http://localhost:8001/user/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

#### 2. Login
```bash
curl -X POST http://localhost:8001/user/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

#### 3. Create Short URL
```bash
curl -X POST http://localhost:8001/api/url \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "url": "https://www.example.com"
  }'
```

#### 4. Get All URLs
```bash
curl -X GET http://localhost:8001/api/url \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### 5. Get Analytics
```bash
curl -X GET http://localhost:8001/api/url/analytics/46Ev-qvw \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### 6. Delete URL
```bash
curl -X DELETE http://localhost:8001/api/url/46Ev-qvw \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### Using JavaScript (Fetch API)

```javascript
// Signup
const signup = async () => {
  const response = await fetch('http://localhost:8001/user/signup', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      name: 'John Doe',
      email: 'john@example.com',
      password: 'password123'
    })
  });
  const data = await response.json();
  return data.token;
};

// Create Short URL
const createShortUrl = async (token, url) => {
  const response = await fetch('http://localhost:8001/api/url', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ url })
  });
  return await response.json();
};

// Get All URLs
const getAllUrls = async (token) => {
  const response = await fetch('http://localhost:8001/api/url', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  return await response.json();
};
```

---

## Security Features

1. **JWT Authentication**: Secure token-based authentication
2. **Password Hashing**: Passwords hashed using bcrypt (10 rounds)
3. **Rate Limiting**: Protection against brute force attacks
4. **Input Validation**: All inputs validated before processing
5. **CORS Enabled**: Cross-origin requests supported
6. **HTTP-Only Cookies**: Tokens stored in HTTP-only cookies for web clients
7. **URL Validation**: Only valid URLs with protocols accepted

---

## Environment Variables

Required environment variables (see `.env.example`):

```env
PORT=8001
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/short-url
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=7d
BASE_URL=http://localhost:8001
```

---

## Notes

- All timestamps are in Unix milliseconds
- JWT tokens expire after 7 days (configurable)
- Short IDs are 8 characters by default (using nanoid)
- Custom short IDs can be any length but must be alphanumeric with hyphens/underscores
- The redirect endpoint (`/url/:shortId`) is public and doesn't require authentication
- All other endpoints require authentication via JWT token
