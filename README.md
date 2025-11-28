# Physical Assessment Monitoring System - Frontend

## 📌 Citation
If you use this software in your project or research, please cite it as follows:

> **Huaman Alvarado, F. A. (2025).** *Physical Assessment Scores Monitoring System - Frontend (Version 1.0.0) [Software].* Zenodo. https://doi.org/10.5281/zenodo.17755928

**BibTeX:**
```bibtex
@software{app_tesis_backend,
  author       = {Huaman Alvarado, Flavio Angello},
  title        = {Physical Assessment Scores Monitoring System - Frontend},
  year         = 2025,
  publisher    = {Zenodo},
  version      = {v1.0.0},
  doi          = {10.5281/zenodo.17755928}
}
```

## 📝 Description

This repository contains the mobile client-side source code for the thesis project: **"IMPLEMENTACIÓN DE UNA HERRAMIENTA DE MONITOREO DE CORRECCIÓN DE EVALUACIONES FÍSICAS EN UNA UNIVERSIDAD EMPLEANDO APRENDIZAJE DE MÁQUINA"**. Pre-built APK available in the Releases section.

The application is built with Flutter and serves as the primary interface for professors to digitize physical assessment scores. It implements a robust video capture pipeline designed to operate reliably, ensuring data integrity during the upload of high-definition video files.

**Key Technologies:**

  * **Framework:** Flutter (Dart).
  * **Architecture:** MVVM-style with Provider for State Management.

## ⚙️ External Services Configuration

The project relies on external configuration files that are excluded from version control for security. You must provide them before building.

### 1\. Firebase Configuration (Google Sign-In)

  * Place your `google-services.json` file inside `android/app/`.
  * Ensure the package name in the JSON matches `pucp.edu.pe.app_tesis` (or your configured ID).
  * *Note: SHA-1 fingerprints must be registered in the Firebase Console for both Debug and Release keystores.*

### 2\. Signing Configuration (Keystore)

To build the Release APK, you must sign the application. Since the keystore is private, you need to generate your own.

1.  **Generate a new Keystore:**
    Run the following command in your terminal (requires JDK installed) and follow the steps shown in console:
    ```bash
    keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
    ```

2.  **Configure the path:**
    Create a file named `key.properties` inside the `android/` folder with the following content.

    ```properties
    storePassword=<your_keystore_password>
    keyPassword=<your_key_password>
    keyAlias=key
    storeFile=<absolute_path_to_your_key.jks>
    ```

### 3\. Environment Variables

Create the environment files in the root directory. These are loaded as assets at runtime based on the build configuration.

**File: `.env.production`**

```env
# Point to your deployed HTTPS backend
API_URL=https://<YOUR_DOMAIN>/api/v1

# Google Web Client ID (From Google Cloud Console -> APIs & Services -> Credentials)
# This is required for Google Sign-In to return an ID Token valid for the backend.
WEB_CLIENT_ID=<YOUR_PRODUCTION_WEB_CLIENT_ID>
```

**File: `.env.development`**

```env
# Point to your local IP for debugging
API_URL=http://<YOUR_LOCAL_IP>:8000/api/v1

# Google Web Client ID (Dev project)
WEB_CLIENT_ID=<YOUR_DEV_WEB_CLIENT_ID>
```

## 🚀 Build & Run Guide

### Prerequisites

  * Flutter SDK (Latest Stable).
  * Android Studio / VS Code with Dart & Flutter plugins.
  * JDK 21.

### 1\. Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/U20212419/app_tesis.git
cd app_tesis
flutter pub get
```

### 2\. Running in Development (Debug)

Connect a physical device or emulator and run:

```bash
flutter run
# By default, this loads .env.development
```

### 3\. Building for Production (Release)

To generate the final optimized artifact (Sideloading):

This command applies tree-shaking, and injects the `production` flag.

```bash
flutter build apk --release --dart-define=ENV=production
```

**Output Location:**
The generated installer will be at:
`build/app/outputs/flutter-apk/app-release.apk`

### 4\. Installation on Android

1.  Transfer the `app-release.apk` to your Android device.
2.  Ensure "Install from unknown sources" is enabled in settings.
3.  Install the application.