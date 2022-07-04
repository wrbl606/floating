## 1.1.0

* Add custom aspect ratio support

## 1.0.0

* BREAKING: Floating class does not have static members anymore. It should be instantiated before use and dispose afterwards with `dispose()`.
* BREAKING: Name changes:
  * from `isInPipMode` to `pipStatus`. It also returns one of `PiPStatus` enum values rather than a `bool`.
  * from `enablePip()` to `enable()`. It also returns one of `PiPStatus` enum values rather than a `bool`.
* Added a `pipStatus$` stream that notifies listeners about changes in the current PiP status.
* Added a `PiPSwitcher` widget that renders proper widgets for current PiP status.

## 0.1.1

* Updated docs

## 0.1.0

* Null-safety migration
* Added tests
* Added docs

## 0.0.1

* Checking if device supports PiP mode
* Checking current PiP status
* Enabling PiP
