//
//  ZoomView.swift
//  ZoomView
//
//  Created by yuki on 2025/01/30.
//

import SwiftUI
import UIKit

public struct ZoomView<Content: View>: View {
    public let minScale: CGFloat
    
    public let maxScale: CGFloat
    
    public var enabled: Bool = true
    
    public var onTap: (() -> Void)? = nil
    
    public var onZoom: ((CGFloat) -> Void)? = nil
    
    public let content: () -> Content
    
    public init(
        minScale: CGFloat = 1.0,
        maxScale: CGFloat = 4.0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.content = content
    }
    
    public var body: some View {
        ZoomViewInternal(
            minScale: self.minScale,
            maxScale: self.maxScale,
            enabled: self.enabled,
            onTap: self.onTap,
            onZoom: self.onZoom,
            content: self.content
        )
//        .background(Color.black.opacity(0.0000000001)) // For ScrollView hidden API
//        .ignoresSafeArea()
    }
}

extension ZoomView {
    public func zoomViewIsEnabled(_ enabled: Bool) -> Self {
        var copy = self
        copy.enabled = enabled
        return copy
    }
    
    public func onTapZoomView(_ action: (() -> Void)?) -> Self {
        var copy = self
        copy.onTap = action
        return copy
    }
    
    public func onZoom(_ action: ((CGFloat) -> Void)?) -> Self {
        var copy = self
        copy.onZoom = action
        return copy
    }
}

struct ZoomViewInternal<Content: View>: UIViewControllerRepresentable {
    let minScale: CGFloat
    let maxScale: CGFloat
    
    let enabled: Bool
    
    let onTap: (() -> Void)?
    
    let onZoom: ((CGFloat) -> Void)?
    
    let content: Content
    
    init(
        minScale: CGFloat,
        maxScale: CGFloat,
        enabled: Bool,
        onTap: (() -> Void)? = nil,
        onZoom: ((CGFloat) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.enabled = enabled
        self.onTap = onTap
        self.onZoom = onZoom
        self.content = content()
        
        print(self.onZoom, self.onTap)
    }
    
    func makeUIViewController(context: Context) -> ZoomViewController<Content> {
        let uiViewController = ZoomViewController(minScale: self.minScale, maxScale: self.maxScale, rootView: self.content)
        uiViewController.enabled = self.enabled
        uiViewController.onTap = self.onTap
        uiViewController.onZoom = self.onZoom
        return uiViewController
    }
    
    func updateUIViewController(_ uiViewController: ZoomViewController<Content>, context: Context) {
        uiViewController.minScale = self.minScale
        uiViewController.maxScale = self.maxScale
        uiViewController.enabled = self.enabled
        uiViewController.onTap = self.onTap
        uiViewController.onZoom = self.onZoom
        uiViewController.content = self.content
    }
}

final class ZoomViewController<Content: View>: UIViewController, UIScrollViewDelegate {
    var maxScale: CGFloat {
        get { self.scrollView.maximumZoomScale }
        set { self.scrollView.maximumZoomScale = newValue }
    }
    
    var minScale: CGFloat {
        get { self.scrollView.minimumZoomScale }
        set { self.scrollView.minimumZoomScale = newValue }
    }
    
    var onTap: (() -> Void)? {
        didSet {
            self.singleTapGesture.isEnabled = self.onTap != nil
        }
    }
    
    var onZoom: ((CGFloat) -> Void)?
    
    var enabled: Bool {
        get { self.scrollView.isUserInteractionEnabled }
        set { self.scrollView.isUserInteractionEnabled = newValue }
    }
    
    var content: Content {
        get { self.hostingController.rootView }
        set { self.hostingController.rootView = newValue }
    }
    
    private let hostingController: UIHostingController<Content>
    
    private let scrollView = UIScrollView()
    
    private lazy var singleTapGesture = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        return gesture
    }()
    
    private lazy var doubleTapGesture = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        gesture.numberOfTapsRequired = 2
        gesture.cancelsTouchesInView = true
        return gesture
    }()
    
    init(minScale: CGFloat, maxScale: CGFloat, rootView: Content) {
        self.scrollView.maximumZoomScale = maxScale
        self.scrollView.minimumZoomScale = minScale
        self.hostingController = UIHostingController(rootView: rootView)
        if #available(iOS 16.4, *) {
            self.hostingController.safeAreaRegions = []
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        self.scrollView.bouncesZoom = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
                
        self.scrollView.addGestureRecognizer(self.singleTapGesture)
        self.scrollView.addGestureRecognizer(self.doubleTapGesture)
        self.singleTapGesture.require(toFail: self.doubleTapGesture)
        
        self.addChild(self.hostingController)
        self.hostingController.willMove(toParent: self)
        
        self.scrollView.addSubview(self.hostingController.view)
        
        self.hostingController.didMove(toParent: self)
        
        view.addSubview(self.scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let preferredContentSize = self.hostingController.sizeThatFits(in: self.scrollView.frame.size)
        
        let wrate = self.scrollView.frame.width / preferredContentSize.width
        let hrate = self.scrollView.frame.height / preferredContentSize.height
        let rate = min(wrate, hrate, 1)
        let targetSize = CGSize(width: preferredContentSize.width * rate, height: preferredContentSize.height * rate)
        
        if self.scrollView.zoomScale == 1 {
            self.hostingController.view.frame.size = targetSize
            self.scrollView.contentSize = targetSize
            self.updateScrollInset()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hostingController.beginAppearanceTransition(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hostingController.endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hostingController.beginAppearanceTransition(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.hostingController.endAppearanceTransition()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.hostingController.view
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.updateScrollInset()
        print(self.onZoom)
        self.onZoom?(scrollView.zoomScale)
    }
    
    private func updateScrollInset() {
        self.scrollView.contentInset = UIEdgeInsets(
            top: max((scrollView.frame.height - self.hostingController.view.frame.height)/2, 0),
            left: max((scrollView.frame.width - self.hostingController.view.frame.width)/2, 0),
            bottom: 0,
            right: 0
        );
    }
    
    @objc private func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        self.onTap?()
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            let pointInView = gesture.location(in: self.hostingController.view)
            let newZoomScale = self.scrollView.maximumZoomScale
            let scrollViewSize = self.scrollView.bounds.size
            
            let width = scrollViewSize.width / newZoomScale
            let height = scrollViewSize.height / newZoomScale
            let x = pointInView.x - (width / 2.0)
            let y = pointInView.y - (height / 2.0)
            
            let zoomRect = CGRect(x: x, y: y, width: width, height: height)
            self.scrollView.zoom(to: zoomRect, animated: true)
        }
    }
}
