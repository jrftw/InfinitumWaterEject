# Version Synchronization Guide

## Problem
The error "The CFBundleVersion of an app extension ('1') must match that of its containing parent app ('2')" occurs when the widget extension's version doesn't match the main app's version.

## Solution

### ✅ **FIXED: Manual Update (Already Done)**
The widget extension version has been updated to match the main app:
- **Main App**: Version 1.0.1, Build 1
- **Widget Extension**: Version 1.0.1, Build 1

### 🔄 **Automatic Synchronization (Future Use)**

#### Method 1: Run the Sync Script
```bash
./sync_versions.sh
```

#### Method 2: Xcode Build Settings
1. Open Xcode
2. Select your project
3. Select the main app target
4. Go to **General** tab → **Identity** section
5. Note the **Version** and **Build** numbers
6. Select the widget extension target
7. Update the **Version** and **Build** to match the main app

#### Method 3: Project File Editing
The versions are stored in `Infinitum Water Eject.xcodeproj/project.pbxproj`:
- `MARKETING_VERSION` = Version number (e.g., "1.0.0")
- `CURRENT_PROJECT_VERSION` = Build number (e.g., "2")

## Version Management Best Practices

### 1. **Single Source of Truth**
- Always update the main app version first
- Then sync all extensions to match

### 2. **Version Numbering**
- **Version**: Semantic versioning (e.g., "1.0.0")
- **Build**: Incremental number for each build (e.g., "1", "2", "3")

### 3. **Before Each Release**
1. Update main app version/build
2. Run `./sync_versions.sh`
3. Clean build folder (Cmd+Shift+K)
4. Build project (Cmd+B)
5. Test all targets

### 4. **Adding New Extensions**
When adding Apple Watch app or other extensions:
1. Add the extension target
2. Run the sync script to match versions
3. Update the script if needed for new targets

## Current Status
✅ **Fixed**: Widget extension version now matches main app (1.0.1 Build 1)
✅ **Script Ready**: `sync_versions.sh` for future synchronization
✅ **Documentation**: This guide for reference

## Troubleshooting

### Error: "CFBundleVersion mismatch"
1. Run `./sync_versions.sh`
2. Clean build folder
3. Rebuild project

### Error: "Script not found"
1. Make script executable: `chmod +x sync_versions.sh`
2. Run from project root directory

### Error: "Permission denied"
1. Check file permissions: `ls -la sync_versions.sh`
2. Make executable: `chmod +x sync_versions.sh`

## Files Modified
- `Infinitum Water Eject.xcodeproj/project.pbxproj` - Updated widget extension versions
- `sync_versions.sh` - Automatic synchronization script
- `VERSION_SYNC_GUIDE.md` - This documentation 