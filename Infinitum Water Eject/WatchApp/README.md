# Apple Watch App Files

These files are prepared for when you add the Apple Watch App target to your Xcode project.

## Files Included:

### WaterEjectWatchApp.swift
- Main Apple Watch app entry point
- Currently has `@main` commented out to avoid conflicts
- Uncomment `@main` when adding Watch App target

### WaterEjectComplication.swift
- Apple Watch complications for watch faces
- Currently has `ComplicationController` commented out
- Uncomment the entire class when adding Watch App target

## How to Use:

1. **Add Watch App Target** in Xcode:
   - File → New → Target
   - Choose "Watch App"
   - Name it "WaterEjectWatchApp"

2. **Copy these files** to the Watch App target:
   - Copy `WaterEjectWatchApp.swift` to the Watch App target
   - Copy `WaterEjectComplication.swift` to the Watch App target

3. **Uncomment the code**:
   - In `WaterEjectWatchApp.swift`: Uncomment `@main`
   - In `WaterEjectComplication.swift`: Uncomment the `ComplicationController` class

4. **Configure App Groups**:
   - Add App Group: `group.com.infinitumimagery.watereject`
   - Enable for both main app and Watch App targets

5. **Build and test** on Apple Watch device

## Features:
- Complete water ejection functionality on Apple Watch
- Device and intensity selection
- Real-time session monitoring
- Premium status checking
- Complications for watch faces 