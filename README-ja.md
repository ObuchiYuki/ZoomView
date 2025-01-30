# ZoomView

en: [English](README.md) | ja: [日本語](README-ja.md)

![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![Platforms](https://img.shields.io/badge/Platforms-iOS-lightgrey) ![License](https://img.shields.io/badge/License-MIT-blue)

`ZoomView` は、SwiftUI でコンテンツのズームイン・ズームアウトを可能にするコンポーネントです。iOS の写真アプリと同じピンチやダブルタップによるズーム挙動を再現し、`ScrollView` を内部で使用することで、SwiftUI の safe area にも対応しています。

## 特徴

- **iOS の写真アプリと同じ操作感**
  ピンチでのズームや、ダブルタップでのズームイン／アウトが自然に行えます。
- **safe area を考慮**
  内部で `UIScrollView` を使用しているため、SwiftUI の safe area に自動で対応します。
- **ダブルタップによるスマートズーム**
  タップ位置を中心に自然にズームイン／ズームアウトが行われます。

## 必要要件

- iOS 14.0 以上

## インストール (Swift Package Manager)

1. Xcode のメニューから **File** > **Add Packages...** を選択
2. 次のリポジトリ URL を入力 (例): `https://github.com/yourusername/ZoomView.git`
3. **ZoomView** パッケージを選択し、プロジェクトに追加する

または、`Package.swift` に以下を追加してください:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ZoomView.git", from: "1.0.0")
]
```

## 使い方

`ZoomView` に任意の SwiftUI コンテンツを渡すだけで、ピンチやダブルタップによるズーム機能を利用できます。

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

##### 

`onTap` 引数を使うことで、ZoomViewへのtapをハンドリングできます。（onTapGestureを利用するとdouble tapが無効になります）下記サンプルでは、シングルタップでナビゲーションバーの表示／非表示を切り替えています:

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



`minScale` や `maxScale` の指定を変更することで、ズームの下限・上限をカスタマイズできます:

```swift
ZoomView(minScale: 1.0, maxScale: 4.0) {
    // コンテンツ
}
```

## ライセンス

[MIT License](LICENSE)
© 2025 Your Name. All rights reserved.
