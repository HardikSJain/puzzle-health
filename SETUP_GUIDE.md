# Puzzle Health - Setup Guide

## New Onboarding Implementation Complete! 🎉

The perfect minimal onboarding flow has been implemented with:
- **Screen 1: The Reveal** - Animated puzzle metaphor
- **Screen 2: The Magic Moment** - Real health data analysis

---

## Setup Instructions

### 1. Install Dependencies

Run the following command to install the new dependencies:

```bash
flutter pub get
```

New dependencies added:
- `health: ^13.3.0` - For accessing Apple Health / Google Fit
- `permission_handler: ^11.3.1` - For managing permissions

---

### 2. iOS Setup (HealthKit)

#### A. Enable HealthKit Capability in Xcode

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select the **Runner** target in the project navigator

3. Go to **Signing & Capabilities** tab

4. Click **+ Capability**

5. Search for and add **HealthKit**

#### B. Permissions Already Configured

The following has already been added to `ios/Runner/Info.plist`:
- `NSHealthShareUsageDescription` - Permission message for reading health data
- `NSHealthUpdateUsageDescription` - Permission message for writing health data

---

### 3. Android Setup (Health Connect)

#### A. Update build.gradle (if needed)

If you encounter issues, you may need to update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34  // Must be at least 33 for Health Connect

    defaultConfig {
        minSdkVersion 26  // Health Connect requires API 26+
        targetSdkVersion 34
    }
}
```

#### B. Permissions Already Configured

The following has already been added to `android/app/src/main/AndroidManifest.xml`:
- `READ_STEPS` - For step count data
- `READ_DISTANCE` - For distance data
- `READ_ACTIVE_CALORIES_BURNED` - For calorie data
- `ACTIVITY_RECOGNITION` - For activity recognition

---

### 4. Test the New Onboarding

#### A. Reset Onboarding State

To test the onboarding flow, you need to reset the app's shared preferences:

**Option 1: Uninstall and reinstall the app**
```bash
# iOS
flutter run --uninstall-first

# OR manually delete from device/simulator
```

**Option 2: Clear app data**
- iOS: Delete app from device/simulator
- Android: Settings → Apps → Puzzle Health → Clear Data

#### B. Run the App

```bash
flutter run
```

You should see:
1. **Screen 1**: Animated puzzle pieces with storytelling (8 seconds)
2. **Screen 2**: Real health data analysis with your actual step history

---

### 5. What's New

#### New Files Created

**Models:**
- `lib/core/models/health_baseline.dart` - User baseline activity patterns
- `lib/core/models/health_target.dart` - Personalized health targets

**Services:**
- `lib/core/services/health_service.dart` - Health data fetching (Apple Health / Google Fit)
- `lib/core/services/health_analyzer.dart` - Baseline calculation and target generation

**Onboarding Pages:**
- `lib/features/onboarding/presentation/pages/onboarding_reveal_page.dart` - Screen 1: The Reveal
- `lib/features/onboarding/presentation/pages/onboarding_magic_page.dart` - Screen 2: The Magic Moment
- `lib/features/onboarding/presentation/widgets/animated_puzzle_pieces.dart` - Puzzle animation widget

**Routes:**
- Updated `lib/routes/routes_constants.dart` - Added new routes
- Updated `lib/routes/routes.dart` - Wired up new onboarding flow

---

### 6. Testing Checklist

- [ ] Onboarding screen 1 shows animated puzzle pieces
- [ ] Haptic feedback triggers when puzzle piece "clicks"
- [ ] Continue button appears after 8 seconds
- [ ] Screen 2 requests health permissions
- [ ] Loading states show with status messages
- [ ] Real health data is fetched (last 30 days)
- [ ] Baseline calculation shows accurate numbers
- [ ] Target is personalized based on baseline
- [ ] Insight message matches user's pattern
- [ ] "Start tracking" button completes onboarding
- [ ] App navigates to home screen
- [ ] Permission denied state works (shows default target)

---

### 7. Known Issues / Notes

#### iOS Simulator
- Health data may not be available in simulator
- Use a real device or manually add health data in the Health app
- To add test data in simulator:
  1. Open Health app
  2. Browse → Activity → Steps
  3. Add Data manually for last 30 days

#### Android Emulator
- Health Connect may not be installed
- Install Health Connect from Play Store (or use real device)
- For testing, create test data in Health Connect app

#### Permission Dialog
- iOS: Shows standard HealthKit permission dialog
- Android: Shows Health Connect permission screen
- Both require user to explicitly grant access

---

### 8. Customization

#### Adjust Animation Speed

Edit `onboarding_reveal_page.dart`:
```dart
_controller = AnimationController(
  duration: const Duration(milliseconds: 8000), // Change this (currently 8 seconds)
  vsync: this,
)
```

#### Adjust Target Algorithm

Edit `health_analyzer.dart` in the `generateTarget()` method to change how targets are calculated based on baseline.

Current strategy:
- <2K steps: +50% increase
- 2-3K: +40% increase
- 3-5K: +25% increase
- 5-7K: +15% increase
- 7-10K: +10% increase
- 10K+: +5-8% increase

#### Customize Insight Messages

Edit `health_analyzer.dart` in the `generateInsight()` method to add more personality or change the tone of insights.

---

### 9. Old Onboarding (Deprecated)

The old 3-screen onboarding is still in the codebase but not used:
- `onboarding_welcome_page.dart`
- `onboarding_connect_page.dart`
- `onboarding_first_focus_page.dart`

These can be safely deleted once you confirm the new flow works.

---

### 10. Next Steps

After testing the onboarding:

1. **Test on real devices** with actual health data
2. **Gather feedback** on the animation timing and messaging
3. **A/B test** different insight message variations
4. **Monitor** permission grant rates
5. **Iterate** on the target generation algorithm based on user outcomes

---

## Troubleshooting

### "Health data not available" error

**iOS:**
- Check that HealthKit capability is enabled in Xcode
- Verify Info.plist has the usage descriptions
- Ensure Health app has data for the last 30 days

**Android:**
- Check that Health Connect is installed
- Verify AndroidManifest.xml has the permissions
- Ensure minSdkVersion is at least 26

### Onboarding doesn't show

The app checks `onboardingCompleted` in SharedPreferences. To reset:
```bash
# Uninstall and reinstall
flutter run --uninstall-first
```

### Animation is choppy

- Run in Release mode for better performance:
  ```bash
  flutter run --release
  ```
- Check that `CADisableMinimumFrameDurationOnPhone` is set to `true` in Info.plist (already done)

---

## Support

For issues or questions:
1. Check the logs for detailed error messages
2. Verify all setup steps are completed
3. Test on a real device (not simulator/emulator)

---

**The onboarding is ready! Test it out and see the magic happen.** ✨
