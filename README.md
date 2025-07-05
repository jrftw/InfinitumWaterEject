# Infinitum Water Eject

A modern iOS app designed to help eject water from electronic devices using scientifically-tuned sound frequencies. Built with SwiftUI and Core Data, featuring a beautiful interface, comprehensive device support, and premium subscription features.

## Features

### Core Functionality
- **Water Ejection**: Generate specific sound frequencies to dislodge water from device speakers and internal components
- **Device Support**: Optimized frequencies for iPhone, iPad, MacBook, Apple Watch, AirPods, and other devices
- **Intensity Levels**: Four levels (Low, Medium, High, Emergency) with appropriate durations and frequencies
- **Real-time Timer**: Visual progress tracking with circular progress indicator and countdown timer
- **Session Management**: Complete session history with detailed analytics and statistics

### User Interface
- **Modern Design**: Clean, intuitive interface with support for light, dark, and auto themes
- **Device Selection**: Easy device picker with icons and descriptions
- **Intensity Picker**: Visual intensity selection with duration information
- **Progress Tracking**: Real-time timer display with progress circle and percentage
- **Responsive Controls**: Start, stop, and complete session buttons

### Premium Features
- **Unlimited Sessions**: No daily limits on water ejection sessions
- **Advanced Analytics**: Detailed session history and device statistics
- **Custom Notifications**: Personalized reminders and alerts
- **Advanced Settings**: Fine-tune frequency and duration settings
- **Ad-Free Experience**: Enjoy the app without advertisements
- **Priority Support**: Get help faster with premium support

### Safety & Support
- **Comprehensive Tips**: Device-specific safety tips and best practices
- **FAQ Section**: Frequently asked questions with detailed answers
- **Contact Support**: Built-in support form with email integration
- **Privacy Policy**: Complete privacy policy with data handling information
- **Terms of Service**: Comprehensive terms and conditions

### Data & Analytics
- **Session History**: Complete record of all water ejection sessions
- **Statistics Dashboard**: Overview of usage patterns and success rates
- **Device Analytics**: Breakdown of device usage and effectiveness
- **Intensity Analysis**: Analysis of intensity level usage and completion rates
- **Export Capabilities**: Data export for backup and analysis

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Local data persistence with CloudKit support
- **AVFoundation**: Audio generation and playback
- **StoreKit**: In-app purchase and subscription management
- **UserNotifications**: Local notification system

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
- **SubscriptionService**: Premium feature management
- **NotificationService**: Local notification handling

## Installation

### Requirements
- iOS 15.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

### Setup
1. Clone the repository
2. Open `Infinitum Water Eject.xcodeproj` in Xcode
3. Select your development team in project settings
4. Build and run on device or simulator

### Widget Extension
To add the widget extension:
1. Create a new Widget Extension target in Xcode
2. Copy the widget files from `WidgetExtension/` folder
3. Configure the widget bundle and deployment target
4. Build and test the widget

## Usage

### Basic Water Ejection
1. Open the app and select your device type
2. Choose the appropriate intensity level
3. Tap "Start Water Ejection"
4. Follow the on-screen timer and safety tips
5. Complete the session when finished

### Safety Guidelines
- Remove device cases and accessories before ejection
- Power off devices completely when possible
- Use gentle motion during ejection
- Let devices dry completely before use
- Consult professionals for severe water damage

### Premium Features
- Upgrade to premium for unlimited sessions
- Access advanced analytics and settings
- Remove advertisements
- Get priority customer support

## Development

### Project Structure
```
Infinitum Water Eject/
├── Models/
│   ├── UserSettings.swift
│   └── WaterEjectionSession.swift
├── Services/
│   ├── CoreDataService.swift
│   ├── NotificationService.swift
│   ├── SubscriptionService.swift
│   └── WaterEjectionService.swift
├── Views/
│   ├── DevicePickerView.swift
│   ├── HistoryView.swift
│   ├── IntensityPickerView.swift
│   ├── MainEjectionView.swift
│   ├── MainTabView.swift
│   ├── PremiumOfferView.swift
│   ├── SettingsView.swift
│   ├── SupportView.swift
│   └── TipsView.swift
└── WidgetExtension/
    └── WaterEjectionWidget.swift
```

### Core Data Model
- **UserSettingsEntity**: User preferences and settings
- **WaterEjectionSessionEntity**: Session data and metadata

### Key Components
- **MainTabView**: Primary navigation structure
- **MainEjectionView**: Core ejection interface
- **HistoryView**: Session history and analytics
- **SettingsView**: App configuration and support
- **TipsView**: Device-specific safety information

## Privacy & Security

### Data Collection
- Minimal data collection for app functionality
- All data stored locally on device
- No personal information transmitted without consent
- Optional analytics for app improvement

### Data Storage
- Core Data with local persistence
- Optional iCloud sync for premium users
- Secure data handling and encryption
- User control over data retention

## Support

### Contact Information
- **Email**: support@infinitumwatereject.com
- **Website**: infinitumwatereject.com
- **Location**: Pittsburgh, PA, USA

### Documentation
- In-app help and FAQ section
- Comprehensive privacy policy
- Detailed terms of service
- Safety guidelines and best practices

## License

Copyright 2025 Infinitum Imagery LLC

Made by JrFTW in Pittsburgh, PA, USA

All rights reserved. This app is proprietary software and may not be redistributed without permission.

## Acknowledgments

- Built with SwiftUI and Core Data
- Audio generation using AVFoundation
- Subscription management with StoreKit
- Local notifications with UserNotifications framework
- Modern iOS design patterns and best practices

---

**Infinitum Water Eject** - Protecting your devices with sound science. 