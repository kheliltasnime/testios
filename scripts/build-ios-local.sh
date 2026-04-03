#!/bin/bash

echo "🔧 Building PlutoVets for iOS Testing..."

cd "$(dirname "$0")/.."

# Build for iOS Simulator
echo "📱 Building for iOS Simulator..."
cd plutovets_mobile
flutter build ios --simulator --release

# Create IPA for sideloading
echo "📦 Creating IPA for testing..."
flutter build ipa --release

echo "✅ Build completed!"
echo "📁 iOS Simulator build: plutovets_mobile/build/ios/iphonesimulator"
echo "📁 IPA build: plutovets_mobile/build/ios/ipa/Runner.ipa"
echo ""
echo "🌐 To test on iPhone:"
echo "1. Install Xcode on a Mac"
echo "2. Open plutovets_mobile/ios/Runner.xcworkspace"
echo "3. Connect iPhone via USB"
echo "4. Select your device in Xcode"
echo "5. Click Run button"
