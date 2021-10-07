# floating

Picture in Picture management for Flutter. **Android only**

## API

PiP mode in desired mode is available only in Android
so iOS and web support is not planned until
the platforms adds native support for such feature.

### Check if PiP is available

```dart
final canUsePiP = await Floating.isPipAvailable;
```

> PiP may be unavailable because of system settings managed
> by admin or device manufacturer. Also, the device may
> have Android version that was released without this feature.

### Check if app is in PiP mode

```dart
final isPiP = await Floating.isInPipMode;
```

When `false` the app can call `Floating.enablePip()` method.
When the app is already in PiP mode user will have an option
to bring the app to it's original size via system UI.

### Enable PiP mode

```dart
final enabled = await Floating.enablePip();
```

When enabled, PiP mode can be ended by the user via system UI.
