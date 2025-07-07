#!/bin/bash

# Sync Versions Script for Infinitum Water Eject
# This script ensures the widget extension version matches the main app

echo "=== Version Synchronization Script ==="

# Get the main app's version and build number from project.pbxproj
MAIN_APP_VERSION=$(grep "MARKETING_VERSION" "Infinitum Water Eject.xcodeproj/project.pbxproj" | head -1 | sed 's/.*MARKETING_VERSION = //' | sed 's/;//')
MAIN_APP_BUILD=$(grep "CURRENT_PROJECT_VERSION" "Infinitum Water Eject.xcodeproj/project.pbxproj" | head -1 | sed 's/.*CURRENT_PROJECT_VERSION = //' | sed 's/;//')

echo "Main App Version: $MAIN_APP_VERSION"
echo "Main App Build: $MAIN_APP_BUILD"

# Update widget extension version and build in project.pbxproj
if [ -f "Infinitum Water Eject.xcodeproj/project.pbxproj" ]; then
    # Update Debug configuration
    sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $MAIN_APP_BUILD;/g" "Infinitum Water Eject.xcodeproj/project.pbxproj"
    sed -i '' "s/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = $MAIN_APP_VERSION;/g" "Infinitum Water Eject.xcodeproj/project.pbxproj"
    
    echo "Updated Widget Extension to Version: $MAIN_APP_VERSION, Build: $MAIN_APP_BUILD"
else
    echo "Project file not found"
fi

echo "=== Version synchronization complete! ==="
echo ""
echo "To apply changes:"
echo "1. Clean the build folder (Cmd+Shift+K)"
echo "2. Build the project (Cmd+B)"
echo "3. The widget extension should now have matching version numbers" 