#!/bin/bash

# Infinitum Water Eject - Apple Watch App Setup Script
# This script automatically sets up the Apple Watch app target and copies necessary files

echo "🚀 Setting up Apple Watch App for Infinitum Water Eject..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "Infinitum Water Eject.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Error: Please run this script from the project root directory${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Step 1: Checking current project structure...${NC}"

# Check if Watch App target already exists
if grep -q "WaterEjectWatchApp" "Infinitum Water Eject.xcodeproj/project.pbxproj"; then
    echo -e "${YELLOW}⚠️  Watch App target already exists. Skipping target creation.${NC}"
else
    echo -e "${BLUE}📋 Step 2: Creating Apple Watch App target...${NC}"
    echo -e "${YELLOW}⚠️  Please manually add the Watch App target in Xcode:${NC}"
    echo -e "${YELLOW}   1. File → New → Target${NC}"
    echo -e "${YELLOW}   2. Choose 'Watch App' under watchOS${NC}"
    echo -e "${YELLOW}   3. Name it 'WaterEjectWatchApp'${NC}"
    echo -e "${YELLOW}   4. Click Finish${NC}"
    echo ""
    read -p "Press Enter when you've added the Watch App target..."
fi

echo -e "${BLUE}📋 Step 3: Creating Watch App directory structure...${NC}"

# Create Watch App directory if it doesn't exist
mkdir -p "WaterEjectWatchApp"

echo -e "${BLUE}📋 Step 4: Copying Watch App files...${NC}"

# Copy Watch App files to the new target directory
cp "Infinitum Water Eject/WatchApp/WaterEjectWatchApp.swift" "WaterEjectWatchApp/"
cp "Infinitum Water Eject/WatchApp/WaterEjectComplication.swift" "WaterEjectWatchApp/"

echo -e "${GREEN}✅ Watch App files copied successfully${NC}"

echo -e "${BLUE}📋 Step 5: Creating Watch App Info.plist...${NC}"

# Create Watch App Info.plist
cat > "WaterEjectWatchApp/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>Water Eject</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.1</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>WKApplication</key>
	<true/>
	<key>WKWatchKitApp</key>
	<true/>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
</dict>
</plist>
EOF

echo -e "${GREEN}✅ Watch App Info.plist created${NC}"

echo -e "${BLUE}📋 Step 6: Creating Watch App entitlements...${NC}"

# Create Watch App entitlements
cat > "WaterEjectWatchApp/WaterEjectWatchApp.entitlements" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.infinitumimagery.watereject</string>
	</array>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
</dict>
</plist>
EOF

echo -e "${GREEN}✅ Watch App entitlements created${NC}"

echo -e "${BLUE}📋 Step 7: Creating setup instructions...${NC}"

# Create setup instructions
cat > "WATCH_APP_SETUP_INSTRUCTIONS.md" << 'EOF'
# Apple Watch App Setup Instructions

## ✅ Files Created
- `WaterEjectWatchApp/WaterEjectWatchApp.swift` - Main Watch App
- `WaterEjectWatchApp/WaterEjectComplication.swift` - Complications
- `WaterEjectWatchApp/Info.plist` - Watch App configuration
- `WaterEjectWatchApp/WaterEjectWatchApp.entitlements` - App Groups

## 📋 Next Steps in Xcode

### 1. Add Watch App Target (if not done already)
1. File → New → Target
2. Choose "Watch App" under watchOS
3. Name it "WaterEjectWatchApp"
4. Click Finish

### 2. Add Files to Watch App Target
1. Right-click on WaterEjectWatchApp target in Xcode
2. Add Files to "WaterEjectWatchApp"
3. Select all files from the `WaterEjectWatchApp/` directory
4. Make sure "Add to target: WaterEjectWatchApp" is checked
5. Click Add

### 3. Configure App Groups
1. Select your project in Xcode
2. Go to Signing & Capabilities for each target:
   - Main app target
   - Widget extension target  
   - Watch App target
3. Click "+ Capability" and add "App Groups"
4. Add group: `group.com.infinitumimagery.watereject`
5. Enable for all three targets

### 4. Build and Test
1. Clean build folder (Cmd+Shift+K)
2. Build project (Cmd+B)
3. Test on device with Apple Watch
4. Verify complications work on watch faces

## 🎯 Features Available
- ✅ Complete water ejection functionality on Apple Watch
- ✅ Device and intensity selection
- ✅ Real-time session monitoring
- ✅ Session start/stop controls
- ✅ Premium status display
- ✅ Complications for watch faces
- ✅ Data synchronization with iPhone app

## 🚨 Troubleshooting
- If build errors occur, ensure all files are added to the correct target
- Verify App Groups are configured for all targets
- Check that Watch App target is set to watchOS platform
- Ensure device has watchOS 8.0+ for testing

## 📱 Testing
- Test on physical Apple Watch device (simulator has limitations)
- Verify complications appear on watch faces
- Test data synchronization between iPhone and Watch
- Check premium features work correctly
EOF

echo -e "${GREEN}✅ Setup instructions created${NC}"

echo -e "${BLUE}📋 Step 8: Updating project configuration...${NC}"

# Create a script to update the project file
cat > "update_project.sh" << 'EOF'
#!/bin/bash

# This script updates the Xcode project to include the Watch App files
# Run this after adding the Watch App target in Xcode

echo "Updating Xcode project configuration..."

# Note: This would require more complex project file manipulation
# For now, manual steps are provided in the instructions

echo "Please follow the manual steps in WATCH_APP_SETUP_INSTRUCTIONS.md"
EOF

chmod +x "update_project.sh"

echo -e "${GREEN}✅ Project update script created${NC}"

echo ""
echo -e "${GREEN}🎉 Apple Watch App setup completed!${NC}"
echo ""
echo -e "${BLUE}📋 What was created:${NC}"
echo -e "  ✅ WaterEjectWatchApp/ directory with all Watch App files"
echo -e "  ✅ Info.plist for Watch App configuration"
echo -e "  ✅ Entitlements file with App Groups"
echo -e "  ✅ Setup instructions (WATCH_APP_SETUP_INSTRUCTIONS.md)"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "  1. Open Xcode"
echo -e "  2. Add Watch App target (File → New → Target → Watch App)"
echo -e "  3. Add files from WaterEjectWatchApp/ directory to the target"
echo -e "  4. Configure App Groups capability"
echo -e "  5. Build and test"
echo ""
echo -e "${BLUE}📖 See WATCH_APP_SETUP_INSTRUCTIONS.md for detailed steps${NC}" 