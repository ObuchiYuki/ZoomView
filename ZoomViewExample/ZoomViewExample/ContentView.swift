//
//  ContentView.swift
//  ZoomViewExample
//
//  Created by yuki on 2025/01/30.
//

import SwiftUI
import ZoomView

struct ZoomContentWithNavigationView: View {
    @State var isFullScreen = false
    
    var body: some View {
        NavigationStack {
            ZoomView {
                Image("mountain")
                    .resizable()
                    .scaledToFit()
            }
            .onTapZoomView {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.isFullScreen.toggle()
                }
            }
            .background(self.isFullScreen ? Color.black : Color.white)
            .navigationBarHidden(self.isFullScreen)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("ZoomView")
        }
    }
}

struct ZoomContentView: View {
    var body: some View {
        ZoomView {
            Image("mountain")
                .resizable()
                .scaledToFit()
        }
    }
}
