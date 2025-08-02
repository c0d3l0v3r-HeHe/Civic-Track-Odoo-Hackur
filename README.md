# CivicTrack

A Flutter app that empowers citizens to easily report local issues such as road damage, garbage, and water leaks. Users can seamlessly track the resolution of these issues and foster engagement within their local community.

## Features

- **User Authentication**: Simple login and signup with Firebase Auth
- **Local Issue Reporting**: Report civic issues in your neighborhood (3-5 km radius)
- **Issue Categories**: 
  - Roads (potholes, obstructions)
  - Lighting (broken or flickering lights)
  - Water Supply (leaks, low pressure)
  - Cleanliness (overflowing bins, garbage)
  - Public Safety (open manholes, exposed wiring)
  - Obstructions (fallen trees, debris)

## Current Status

✅ **Completed:**
- User authentication (Login/Signup) with Firebase
- Basic app structure with navigation
- Simple home screen with action cards

🚧 **Coming Soon:**
- Issue reporting functionality
- Map view with location-based filtering
- Photo upload for reports
- Status tracking and notifications
- Admin panel for issue management

## Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Firebase project setup

### Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication and choose Email/Password as sign-in method
3. Enable Cloud Firestore
4. Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:
   - Get your config from Project Settings > General > Your apps
   - Replace `your-api-key`, `your-project-id`, etc. with actual values

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Get dependencies: `flutter pub get`
4. Configure Firebase (see above)
5. Run the app: `flutter run`

## App Structure

```
lib/
├── main.dart                 # App entry point with Firebase setup
├── firebase_options.dart      # Firebase configuration
└── screens/
    ├── login_screen.dart     # User login
    ├── signup_screen.dart    # User registration
    └── home_screen.dart      # Main dashboard
```

## Technologies Used

- **Flutter**: Cross-platform mobile development
- **Firebase Auth**: User authentication
- **Cloud Firestore**: Database (ready for future features)
- **Material Design**: UI components

## License

This project is part of the CivicTrack initiative to improve community engagement.
# Civic-Track-Odoo-Hackur
