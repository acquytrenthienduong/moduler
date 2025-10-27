#!/bin/bash

echo "🚀 Setting up Core Package..."

# Navigate to core package
cd packages/core

echo "📦 Installing core package dependencies..."
fvm flutter pub get

echo "🔨 Running build_runner for core package..."
fvm flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ Core package setup complete!"

# Navigate back to root
cd ../..

# Navigate to app
cd skeleton_template

echo "📦 Installing app dependencies..."
fvm flutter pub get

echo "🔨 Running build_runner for app..."
fvm flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ Setup complete! Ready to run the app."

