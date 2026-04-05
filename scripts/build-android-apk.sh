#!/bin/bash

echo "🔧 Building PlutoVets Android APK..."

cd "$(dirname "$0")/../plutovets_mobile"

# Check if Android SDK is available
if [ ! -d "$ANDROID_HOME" ]; then
    echo "❌ Android SDK not found. Please install Android Studio first."
    echo "📥 Download from: https://developer.android.com/studio"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Build APK
echo "🏗️ Building APK..."
flutter build apk --release

# Check if build succeeded
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ APK built successfully!"
    echo "📁 Location: build/app/outputs/flutter-apk/app-release.apk"
    echo "📱 Install on Android: adb install build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ Build failed!"
    exit 1
fi
