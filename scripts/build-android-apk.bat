@echo off
echo 🔧 Building PlutoVets Android APK...

cd /d "%~dp0\..\plutovets_mobile"

REM Check if Android SDK is available
if not defined ANDROID_HOME (
    echo ❌ Android SDK not found. Please install Android Studio first.
    echo 📥 Download from: https://developer.android.com/studio
    pause
    exit /b 1
)

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Installing dependencies...
flutter pub get

REM Build APK
echo 🏗️ Building APK...
flutter build apk --release

REM Check if build succeeded
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ APK built successfully!
    echo 📁 Location: build\app\outputs\flutter-apk\app-release.apk
    echo 📱 Install on Android: adb install build\app\outputs\flutter-apk\app-release.apk
    echo 🌐 Alternative: Copy APK to phone and install
) else (
    echo ❌ Build failed!
    pause
    exit /b 1
)

pause
