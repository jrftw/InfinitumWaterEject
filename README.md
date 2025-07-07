# Infinitum Water Eject

A comprehensive iOS app designed to protect your devices from water damage using optimized sound frequencies. The app generates specific audio frequencies that help dislodge water from device speakers and other components.

## Features

### Core Functionality
- **Multi-Device Support**: Optimized frequencies for iPhone, iPad, MacBook, Apple Watch, AirPods, and other devices
- **Intensity Levels**: Multiple ejection intensities (Low, Medium, High, Emergency, Realtime)
- **Real-time Control**: Dynamic frequency adjustment during active sessions
- **Session Tracking**: Complete history and analytics of all water ejection sessions
- **Safety Features**: Built-in safety checks and user guidance

### Premium Features (Subscription Required)
- **Ad-Free Experience**: Remove all advertisements
- **Unlimited Sessions**: No daily limits on water ejection sessions
- **Advanced Analytics**: Detailed insights into device protection habits
- **Apple Watch Widgets**: Quick access to controls and statistics on your Apple Watch
- **Apple Watch App**: Full water ejection functionality on Apple Watch
- **Custom Frequency Presets**: Save and reuse custom frequency settings
- **Export Session Data**: Backup and analyze your session history
- **Cloud Backup & Sync**: Secure cloud storage for your data (uses Apple iCloud/CloudKit free tier, no ongoing cost)
- **Priority Customer Support**: Get help faster with premium support
- **Custom Notification Schedules**: Personalized reminder settings

### Apple Watch Integration
- **Watch App**: Complete water ejection functionality on Apple Watch
- **Complications**: Quick access to session statistics on watch faces
- **Widgets**: Multiple widget sizes showing session data and quick controls
- **Real-time Sync**: Instant synchronization between iPhone and Apple Watch

### Widget Support
- **Small Widget**: Session count and last activity
- **Medium Widget**: Session statistics and success rate
- **Large Widget**: Comprehensive stats with detailed metrics
- **Real-time Updates**: Widgets update automatically with new session data

## Subscription Plans

### Monthly Premium
- $0.99/month
- All premium features included
- Cancel anytime

### Yearly Premium
- $4.99/year (Save 50%)
- All premium features included
- Best value option

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Local data persistence with CloudKit support
- **AVFoundation**: Audio generation and playback
- **StoreKit**: In-app purchase and subscription management
- **UserNotifications**: Local notification system
- **WidgetKit**: iOS and watchOS widget support
- **ClockKit**: Apple Watch complications

### Audio Generation
- **Frequency Optimization**: Device-specific frequencies for maximum effectiveness
- **Safe Volume Levels**: Controlled amplitude to prevent device damage
- **Real-time Generation**: Dynamic audio buffer creation and playback
- **Variation Patterns**: Subtle frequency variations for enhanced effectiveness

### Data Models
- **WaterEjectionSession**: Complete session tracking with metadata
- **UserSettings**: User preferences and configuration
- **DeviceType**: Supported device types with optimized parameters
- **IntensityLevel**: Ejection intensity levels with duration mapping

### Services
- **WaterEjectionService**: Core ejection logic and audio management
- **CoreDataService**: Data persistence and management
- **SubscriptionService**: Premium feature management with StoreKit integration
- **NotificationService**: Local notification handling
- **AdMobService**: Advertisement management (disabled for premium users)

### Widget & Watch Integration
- **Shared UserDefaults**: Data synchronization between app and widgets
- **Timeline Provider**: Real-time widget updates
- **Complication Support**: Apple Watch face complications
- **Watch App**: Native Apple Watch application

## Installation

### Requirements
- iOS 15.6 or later
- watchOS 8.0 or later (for Apple Watch features)
- Xcode 14.0 or later
- Swift 5.7 or later

### Setup
1. Clone the repository
2. Open `Infinitum Water Eject.xcodeproj` in Xcode
3. Select your development team in project settings
4. Configure App Groups for widget data sharing
5. Set up StoreKit configuration for testing
6. Build and run on device or simulator

### Widget Extension Setup
1. Add Widget Extension target in Xcode
2. Configure App Groups for data sharing
3. Set up widget timeline provider
4. Test on device with different widget sizes

### Apple Watch App Setup
1. Add Watch App target in Xcode
2. Configure complications
3. Set up data synchronization
4. Test on Apple Watch device

## Usage

### Basic Water Ejection
1. Select your device type
2. Choose intensity level
3. Tap "Start Ejection"
4. Let the process complete
5. Allow device to dry completely

### Premium Features
1. Upgrade to Premium in Settings
2. Choose monthly or yearly plan
3. Enjoy ad-free experience
4. Access Apple Watch widgets
5. Use advanced analytics

### Apple Watch Usage
1. Open Water Eject app on Apple Watch
2. Select device and intensity
3. Start ejection directly from watch
4. Monitor progress in real-time
5. View session statistics

### Widget Usage
1. Add Water Eject widget to home screen
2. Choose widget size (small, medium, large)
3. View session statistics at a glance
4. Quick access to recent activity

## Safety Guidelines

### Important Notes
- **Not a Guarantee**: This app is not a guarantee against water damage
- **Professional Help**: Seek professional repair for severe water damage
- **Device Limits**: Some devices may not respond to audio frequencies
- **Volume Caution**: Keep volume at safe levels to avoid hearing damage
- **Drying Time**: Always allow devices to dry completely before use

### Best Practices
- Act quickly after water exposure
- Remove cases and accessories before ejection
- Use silica gel packets for faster drying
- Never use heat sources to dry electronics
- Test device functionality after drying

## Privacy & Data

### Data Collection
- **Session Data**: Local storage of ejection sessions
- **Usage Analytics**: Anonymous usage statistics
- **No Personal Data**: No personal information collected
- **Local Processing**: All data processed locally

### Data Sharing
- **iCloud Sync**: Optional cloud backup (premium feature)
- **No Third Parties**: Data never shared with third parties
- **User Control**: Complete control over data export and deletion

## Support

### Contact Information
- **Email**: support@infinitumimagery.com
- **Website**: https://infinitumimagery.com
- **Premium Support**: Priority support for premium users

### Troubleshooting
- **Audio Issues**: Check device volume and audio settings
- **Widget Problems**: Restart device and re-add widgets
- **Watch Sync**: Ensure both devices are connected
- **Subscription**: Contact App Store support for billing issues

## Legal

### Terms of Service
- **Usage Agreement**: By using the app, you agree to our terms
- **Liability**: App is provided "as is" without warranties
- **Updates**: Terms may be updated with notice
- **Jurisdiction**: Governed by laws of Pennsylvania, USA

### Privacy Policy
- **Data Protection**: Your privacy is our priority
- **Transparency**: Clear information about data usage
- **User Rights**: Control over your personal data
- **Compliance**: Follows applicable privacy laws

## Development

### Contributing
- Fork the repository
- Create feature branch
- Submit pull request
- Follow coding standards
- Include tests

### Testing
- **Unit Tests**: Core functionality testing
- **UI Tests**: User interface testing
- **Integration Tests**: Widget and watch integration
- **StoreKit Testing**: Subscription flow testing

## Version History

### Version 1.0.0
- Initial release with core functionality
- Multi-device support
- Session tracking
- Basic analytics

### Version 1.1.0
- Premium subscription features
- Apple Watch app and complications
- iOS widgets
- Advanced analytics
- Ad-free experience for premium users

## Made by JrFTW in Pittsburgh, PA, USA

Infinitum Imagery LLC - Protecting your devices, one frequency at a time. 