# ZoomView

en: [English](README.md) | ja: [日本語](README_ja.md)

![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![Platforms](https://img.shields.io/badge/Platforms-iOS-lightgrey) ![License](https://img.shields.io/badge/License-MIT-blue)

`ZoomView` is a SwiftUI component that allows users to zoom in and out of content, emulating the same pinch and double-tap zoom behavior as the iOS Photos app. It also respects SwiftUI’s safe area by utilizing a `ScrollView` internally.

## Features
- **Same behavior as iOS Photos app**
  - Pinch to zoom, double-tap to quickly zoom in/out, and auto-centers the content.
- **Safe area aware**
  - Automatically accounts for safe area insets by using a `UIScrollView` under the hood.
- **Smart zoom via double tap**
  - Double-tapping on the content smoothly zooms in (or out) around the tapped point.

## Requirements
- iOS 14.0+

## Installation (Swift Package Manager)
1. In Xcode, select **File** > **Add Packages...**
2. Enter your repository URL, for example: `https://github.com/yourusername/ZoomView.git`
3. Select the **ZoomView** package and add it to your project.

Alternatively, add the following to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ZoomView.git", from: "1.0.0")
]
```

## Usage

### Minimal Example
Use `ZoomView` with any SwiftUI content to enable pinch/zoom gestures and double-tap zoom.

```swift
import SwiftUI
import ZoomView

struct ZoomContentView: View {
    var body: some View {
        ZoomView {
            Image("mountain")
                .resizable()
                .scaledToFit()
        }
    }
}
```

### With Navigation and Full Screen Toggle
You can easily toggle a full-screen mode by hooking into the `onTap` closure. In the example below, a single tap toggles the full-screen state, hiding the navigation bar:

```swift
import SwiftUI
import ZoomView

struct ZoomContentWithNavigationView: View {
    @State var isFullScreen = false
    
    var body: some View {
        NavigationStack {
            ZoomView(onTap: {
                withAnimation(.easeInOut(duration: 0.23)) {
                    self.isFullScreen.toggle()
                }
            }) {
                Image("mountain")
                    .resizable()
                    .scaledToFit()
            }
            .background(self.isFullScreen ? Color.black : Color.white)
            .navigationBarHidden(self.isFullScreen)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("ZoomView")
        }
    }
}
```

Feel free to customize `minScale` and `maxScale` in the initializer if you want different zoom limits:

```swift
ZoomView(minScale: 1.0, maxScale: 4.0) {
    // Content
}
```

## License
[MIT License](LICENSE) 
© 2025 Your Name. All rights reserved.
