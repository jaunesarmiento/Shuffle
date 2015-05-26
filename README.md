# Shuffle

Shuffle is a UI framework for your card swiping needs.


## Installation

> **Embedded frameworks require a minimum deployment target of iOS 8.**

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Shuffle into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Shuffle', '~> 0.0.1'
```

Then, run the following command:

```bash
$ pod install
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate Shuffle into your project manually.

#### Embedded Framework

- Add Shuffle as a [submodule](http://git-scm.com/docs/git-submodule) by opening the Terminal, `cd`-ing into your top-level project directory, and entering the following command:

```bash
$ git submodule add https://github.com/Shuffle/Shuffle.git
```

- Open the new `Shuffle` folder, and drag the `Shuffle.xcodeproj` into the Project Navigator of your application's Xcode project.

> It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `Shuffle.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- And that's it!
> The `Shuffle.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.
---