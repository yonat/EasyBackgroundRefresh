# EasyBackgroundRefresh

Easy background refresh registration, scheduling, execution, and completion.
`BGTaskScheduler` for the lazy.

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EasyBackgroundRefresh.svg)](https://img.shields.io/cocoapods/v/EasyBackgroundRefresh.svg)
[![Platform](https://img.shields.io/cocoapods/p/EasyBackgroundRefresh.svg?style=flat)](http://cocoapods.org/pods/EasyBackgroundRefresh)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


## Usage

For fast refreshes:

```swift
struct MyApp: App {

    let backgroundRefresh = EasyBackgroundRefresh(autoCompleteDelay: 3) { _ in
        // quickly refresh your data in less than autoCompleteDelay seconds
    }
    
    ...
}
```

For longer refreshes:

```swift
struct MyApp: App {

    let backgroundRefresh = EasyBackgroundRefresh { backgroundRefresh in
        backgroundRefresh.isProcessing = true
        defer { backgroundRefresh.isProcessing = false }
        // refresh your data, take up to 30 seconds
    }
    
    ...
}
```

**Note:**

Remember to enable background refresh and add Info.plist keys as described in [Apple docs](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background/using_background_tasks_to_update_your_app).

By default, EasyBackgroundRefresh uses your app Bundle ID as the background task ID. You can change that by passing a different value to init:

```swift
let backgroundRefresh = EasyBackgroundRefresh(taskIdentifier: "io.another.identifier")
```

## Installation

### CocoaPods:

```ruby
pod 'EasyBackgroundRefresh'
```

### Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yonat/EasyBackgroundRefresh", from: "1.0.1")
]
```

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.txt
