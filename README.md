# NurtureSync

## Overview

NurtureSync is an innovative platform designed for comprehensive health management, particularly focused on individuals managing thyroid and diabetes. This application leverages AI to deliver personalized insights, medical analysis, and much more.

---

## Prerequisites

Before setting up and running the application, ensure the following tools and software are installed on your system:

1. **Flutter SDK** ([Installation Guide](https://flutter.dev/docs/get-started/install))
2. **Android Studio** ([Download Here](https://developer.android.com/studio))
3. **Python 3.8+** ([Download Here](https://www.python.org/downloads/))
4. **pip** (Python package manager)
5. **Uvicorn** (Install using `pip install uvicorn`)
6. **Git** ([Download Here](https://git-scm.com/downloads))

---

## Getting Started

Follow these steps to set up the application:

### 1. Clone the Repository

```bash
git clone git@github.com:Nurture-Sync/Nurture-Sync-Combined.git

cd Nurture-Sync-Combined

```

### 2. Launch an Emulator

#### Using Android Studio:

1. Open Android Studio.
2. Navigate to `Tools > Device Manager` (or `AVD Manager`).
3. Create a new virtual device or select an existing one.
4. Click the green play button to start the emulator.

#### Using Flutter:

1. List available emulators:
   ```bash
   flutter emulators
   ```
2. Launch the desired emulator:
   ```bash
   flutter emulators --launch <emulator_name>
   ```
3. Verify devices connected:
   ```bash
   flutter devices
   ```

### 3. Run the App

1. Start the Flutter app:
   ```bash
   flutter run
   ```

---

### 4. Backend Setup

1. Navigate to the backend folder:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```
2. Start the backend server:
   ```bash
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```
3. Verify API functionality:
   Open [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs) in your browser to explore the API documentation.

---

## Additional Commands

### Check Flutter Installation

Run the following command to verify your Flutter setup:

```bash
flutter doctor
```

This will display any missing dependencies or configuration issues.

### Verify Emulator Setup

Check available devices and emulators:

```bash
flutter devices
```

---

## Troubleshooting

1. **Emulator not launching**:

   - Ensure the Android SDK is installed and configured correctly in Android Studio.
   - Run `flutter doctor` to check for any missing components.

2. **Backend not starting**:

   - Verify that Python 3.8+ is installed.
   - Check if `uvicorn` is installed using `pip list`. If not, install it using `pip install uvicorn`.

3. **API calls not working**:

   - Confirm the backend server is running on [http://127.0.0.1:8000](http://127.0.0.1:8000).
   - Check if there are any syntax or dependency issues in the backend code.

---

### Authors

- Nandini Kuppala
- Vishal A S
