#!/bin/bash

# Publishing script for react-native-voice-with-recording

set -e

echo "🚀 Starting publishing process for react-native-voice-with-recording"

# Check if we're logged in to npm
echo "📋 Checking npm login status..."
if ! npm whoami > /dev/null 2>&1; then
    echo "❌ Not logged in to npm. Please run 'npm login' first."
    exit 1
fi

echo "✅ Logged in to npm as $(npm whoami)"

# Check if package name is available
echo "🔍 Checking package name availability..."
if npm search react-native-voice-with-recording 2>/dev/null | grep -q "react-native-voice-with-recording"; then
    echo "❌ Package name 'react-native-voice-with-recording' is already taken."
    echo "   Please choose a different name in package.json"
    exit 1
fi

echo "✅ Package name is available"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the package
echo "🔨 Building package..."
npm run build

# Check if build was successful
if [ ! -f "dist/index.js" ]; then
    echo "❌ Build failed. dist/index.js not found."
    exit 1
fi

echo "✅ Build successful"

# Show what will be published
echo "📋 Files that will be published:"
npm pack --dry-run

# Ask for confirmation
echo ""
read -p "🤔 Do you want to publish this package? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Publishing cancelled."
    exit 0
fi

# Publish the package
echo "📤 Publishing to npm..."
npm publish

echo "✅ Package published successfully!"
echo "🌐 View your package at: https://www.npmjs.com/package/react-native-voice-with-recording"

# Test installation
echo "🧪 Testing installation..."
mkdir -p /tmp/test-install
cd /tmp/test-install
npm init -y > /dev/null 2>&1
npm install react-native-voice-with-recording
echo "✅ Installation test successful"

echo "🎉 Publishing process completed successfully!" 