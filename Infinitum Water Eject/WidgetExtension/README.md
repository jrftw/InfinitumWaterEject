# Widget Extension Setup

To add the widget extension to your app:

## Steps:

1. **Create a new Widget Extension target:**
   - In Xcode, go to File > New > Target
   - Choose "Widget Extension"
   - Name it "WaterEjectionWidgetExtension"
   - Make sure "Include Configuration Intent" is unchecked
   - Click "Finish"

2. **Add the widget code:**
   - Replace the generated widget code with the code from `WaterEjectionWidget.swift`
   - The widget will provide quick access to water ejection functionality

3. **Configure the widget:**
   - The widget supports Small and Medium sizes
   - Provides session statistics and quick start button
   - Deep links to the main app

## Widget Features:
- Session count display
- Last session information
- Quick start button for water ejection
- Deep linking to main app

## Note:
The widget extension should be a separate target to avoid conflicts with the main app's @main attribute. 