# WeFeed: Food Donation Application

**Designed by Ganesh Kothule**

Now open http://localhost:8085 in your browser.

---

## 📖 Project Description

### **WeFeed: Food Donation Application**
• Developed a food donation mobile and web application using Flutter (Dart).  
• Built a system where donors can upload food details with photo, description, and location.  
• Enabled NGOs or receivers to view donor information and contact them to collect the food.  
• Used MySQL for backend database management to store user and donation data.  

---

## 🌐 Live Web Demo & App Download

| Platform | Download / Access | Instructions |
| :--- | :--- | :--- |
| 📱 **Android App (APK)** | https://drive.google.com/file/d/13VW3yTlWMjGPQ2Yx5MGlxcqbVo3d8e7U/view?usp=sharing| Download & install `WeFeed_FoodDonation_v1.0.apk` on any Android device |
| 🌐 **Live Web App** | Now open http://localhost:8080 in your browser. |
| 💻 **Local Dev Server** | `http://localhost:8085` | Run locally using Flutter or Python static server (see below) |

---

## ✨ Key Features

### 🍲 For Donors
- **Food Donation Upload**: Donors can list surplus cooked food, raw grocery, or bakery items with images, title, description, quantity, expiry time, address, and pincode.
- **Real-time Status Tracking**: View donation listing status (`Available`, `Approved`, `Picked Up`).
- **Donation History**: Track past donations and impact made.

### 🏢 For NGOs & Receivers
- **Browse Food Listings**: View available food donations in real time with location and donor contact details.
- **One-Click Food Claim / Pickup Request**: Request food pickups from nearby donors.
- **NGO Dashboard & Statistics**: Track total meals served, active requests, and verified partner badge.

### 🗄️ MySQL Database Management
- Comprehensive relational schema for high data integrity across users, organizations, donations, and pickup lifecycles.
- Ready-to-use schema script located in [`database/wefeed_database.sql`](database/wefeed_database.sql).

---

## 🏗️ Architecture & Technology Stack

- **Frontend & Mobile**: Flutter 3.x (Dart)
- **UI/UX Design**: Material Design 3, Google Fonts (`Poppins`, `Montserrat`), Custom Glassmorphism Theme
- **Backend & Database**: MySQL 8.0+ / Cloud Firestore hybrid support
- **State Management & Routing**: Flutter Navigator with role-based routing (Donor / NGO)

---

## 📂 Project Structure

```text
WeFeed_Food_Donation_App/
├── database/
│   └── wefeed_database.sql       # Complete MySQL database schema & sample data
├── lib/
│   ├── main.dart                 # Application entry point
│   └── screens/
│       ├── splash_screen.dart    # Splash screen with Ganesh Kothule branding
│       ├── signin_screen.dart    # Login & role-based quick test access
│       ├── signup_screen.dart    # User registration
│       ├── choose_user.dart      # Donor vs NGO role selection
│       ├── donarhome_screen.dart # Donor Dashboard & listings
│       ├── donar_screen.dart     # Food donation creation form
│       ├── ngohome_screen.dart   # NGO Dashboard & partner statistics
│       ├── Ngo_food.dart         # NGO food browsing & approval feed
│       ├── profile_screen.dart   # User profile management
│       └── donation_history.dart # Complete donation logs
├── android/                      # Android native configuration & SDK 35 support
├── web/                          # Flutter web support files
└── README.md                     # Project documentation & links
```

---

## 🚀 Running the Project Locally

### 1. Prerequisites
- Flutter SDK (3.x or higher)
- Dart SDK
- Python 3 (for serving the build on localhost)

### 2. Run on Web (Localhost)
```bash
# Get dependencies
flutter pub get

# Build web release
flutter build web --release

# Serve on localhost:8080
python -m http.server 8080 --directory build/web
```
Now open [http://localhost:8080](http://localhost:8080) in your browser.

### 3. Run or Build Android APK
```bash
# Run on connected device / emulator
flutter run

# Build release/debug APK
flutter build apk --debug
```
The APK will be generated at:
`build/app/outputs/flutter-apk/app-debug.apk`

---

## 👤 Designer & Developer

- **Designed & Developed by**: **Ganesh Kothule**
- **Project**: WeFeed - Food Waste Management & Donation Platform
