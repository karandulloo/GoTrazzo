#!/bin/bash

# Trazzo - Run Flutter App

echo "📱 Starting Trazzo Mobile App..."

cd "$(dirname "$0")/mobile/trazzo_app"

# Get dependencies
flutter pub get

# Run app
flutter run
