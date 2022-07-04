# floating

Picture in Picture management for Flutter. **Android only**

![Picture in picture demo](assets/example.gif)

## App configuration

Add `android:supportsPictureInPicture="true"` line to the `<activity>` tag in `android/src/main/AndroidManifest.xml`:

```xml
<manifest>
   <application>
        <activity
            android:name=".MainActivity"
            android:supportsPictureInPicture="true"
            ...
```

## Widget

This package provides a helper `PiPSwitcher` widget for switching the displayed widgets according to current PiP status. Use it like so:

```dart
PiPSwitcher(
    childWhenDisabled: Scaffold(...),
    childWhenEnabled: JustVideo(), 
)
```

## API

PiP mode in desired mode is available only in Android
so iOS and web support is not planned until
the platforms adds native support for such feature.

### Create a Floating instance

```dart
final floating = Floating();
```

When you're done with the PiP functionality, make sure you're
disposing the instance:

```dart
floating.dispose();
```

### Check if PiP is available

```dart
final canUsePiP = await floating.isPipAvailable;
```

> PiP may be unavailable because of system settings managed
> by admin or device manufacturer. Also, the device may
> have Android version that was released without this feature.

### Check if app is in PiP mode

```dart
final currentStatus = await floating.pipStatus;
```

Possible statuses:

| Status | Description | Will `enable()` have an effect? |
| ------ | ----------- | ------------------------------ |
| disabled | PiP is available to use but currently disabled. | Yes |
| enabled | PiP is enabled. The app can display content but will not receive user inputs until the user decides to bring the app to it's full size. | No |
| unavailable | PiP is disabled on given device. | No |

### Enable PiP mode

```dart
final statusAfterEnabling = await floating.enable();
```

The default 16/9 aspect ratio can be overridden with custom `Rational`.
Eg. to make PiP square use: `.enable(Rational(1, 1))` or `.enable(Rational.square())`.

When enabled, PiP mode can be toggled off by the user via system UI.
