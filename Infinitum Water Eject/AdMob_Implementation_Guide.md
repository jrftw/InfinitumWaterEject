# AdMob Banner Ads Implementation Guide

## Overview
This document outlines the banner ad implementation in Infinitum Water Eject using Google AdMob.

## AdMob Configuration

### App ID
- **Production**: `ca-app-pub-6815311336585204~5510127729`
- **Banner Ad Unit ID**: `ca-app-pub-6815311336585204/1784836834`

### Test IDs (for development)
- **Test Banner Ad Unit ID**: `ca-app-pub-3940256099942544/2934735716`

## Implementation Details

### Files Modified
1. **AdMobService.swift** - Core ad management service
2. **Info.plist** - AdMob configuration and permissions
3. **Infinitum_Water_EjectApp.swift** - App initialization
4. **MainEjectionView.swift** - Banner ad at bottom (when not ejecting)
5. **HistoryView.swift** - Banner ad at bottom of session list
6. **SettingsView.swift** - Banner ad at bottom of settings
7. **TipsView.swift** - Banner ad at bottom of tips
8. **SupportHelpView.swift** - Banner ad at bottom of support

### Ad Placement Strategy
- **Non-intrusive**: Ads placed at bottom of content, not blocking core functionality
- **Contextual**: Ads only show when appropriate (e.g., not during active water ejection)
- **Responsive**: Ads adapt to different screen sizes
- **Conditional**: Ads only display after AdMob SDK is initialized

### Key Features
1. **ConditionalBannerAdView**: Shows loading placeholder until AdMob initializes
2. **Error Handling**: Graceful fallback if ads fail to load
3. **Smart Placement**: Ads don't interfere with critical app functions
4. **User Experience**: Smooth integration without disrupting app flow

## Testing

### Development Testing
1. Uncomment the test ad unit ID in `AdMobService.swift`
2. Comment out the production ad unit ID
3. Test on device or simulator

### Production Deployment
1. Ensure production ad unit ID is active
2. Comment out test ad unit ID
3. Verify ads load correctly in production

## AdMob Console Setup

### Required Steps
1. Create AdMob account
2. Add app with bundle identifier
3. Create banner ad unit
4. Configure ad unit settings
5. Add SKAdNetworkItems for iOS 14+ tracking

### Privacy Compliance
- **NSUserTrackingUsageDescription**: Added to Info.plist
- **SKAdNetworkItems**: Configured for iOS 14+ tracking
- **GADApplicationIdentifier**: App ID configured

## Best Practices

### Ad Placement
- ✅ Bottom of content areas
- ✅ Non-critical screens
- ✅ When user is not actively using core features
- ❌ Never during active water ejection
- ❌ Never blocking primary controls

### User Experience
- ✅ Smooth loading with placeholders
- ✅ Graceful error handling
- ✅ Non-intrusive placement
- ✅ Responsive design
- ❌ No popup or interstitial ads
- ❌ No ads during critical operations

## Troubleshooting

### Common Issues
1. **Ads not loading**: Check network connection and ad unit ID
2. **Test ads not showing**: Ensure test device is added to AdMob console
3. **Production ads not showing**: Verify ad unit is active and approved

### Debug Information
- Check console logs for ad loading status
- Verify AdMob initialization in app startup
- Confirm Info.plist configuration

## Revenue Optimization

### Tips for Better Performance
1. **Strategic Placement**: Ads in high-traffic areas
2. **User Engagement**: Place ads where users spend time
3. **Content Relevance**: Ads appear in relevant contexts
4. **Load Times**: Optimize ad loading for better UX

### Analytics
- Monitor ad performance in AdMob console
- Track user engagement with ads
- Analyze revenue patterns
- Optimize placement based on data

## Future Enhancements

### Potential Improvements
1. **Interstitial Ads**: For premium features
2. **Rewarded Ads**: For bonus features
3. **Native Ads**: More integrated ad experience
4. **A/B Testing**: Different ad placements
5. **Smart Loading**: Load ads based on user behavior

### Considerations
- Maintain user experience quality
- Balance revenue with app functionality
- Follow platform guidelines
- Respect user privacy preferences 