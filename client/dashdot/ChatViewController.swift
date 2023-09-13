//
//  ChatViewController.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-08-05.
//

import UIKit
import SwiftUI

struct ChatView: View {
    struct ChatViewRepresentable: UIViewControllerRepresentable {
        var contentView: () -> any View
        var accessoryView: (UITextDocumentProxy, InputViewProxy) -> any View
        var inputView: (UITextDocumentProxy, InputViewProxy) -> any View
        
        func makeUIViewController(context: Context) -> ChatViewController {
            ChatViewController.instantiate(
                contentView: contentView,
                accessoryView: accessoryView,
                inputView: inputView
            )!
        }
        
        func updateUIViewController(_ uiViewController: ChatViewController, context: Context) {
            uiViewController.updateContent(
                contentView: contentView,
                accessoryView: accessoryView,
                inputView: inputView
            )
        }
    }
    
    @ViewBuilder var contentView: () -> any View
    @ViewBuilder var accessoryView: (UITextDocumentProxy, InputViewProxy) -> any View
    @ViewBuilder var inputView: (UITextDocumentProxy, InputViewProxy) -> any View
    
    var body: some View {
        ChatViewRepresentable(
            contentView: contentView,
            accessoryView: accessoryView,
            inputView: inputView
        )
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

class ChatViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private var contentViewBuilder: () -> AnyView
    private var accessoryViewBuilder: (UITextDocumentProxy, InputViewProxy) -> AnyView
    private var inputViewBuilder: (UITextDocumentProxy, InputViewProxy) -> AnyView
    
    private weak var hostingController: UIHostingController<AnyView>?
    private var accessory: InputViewController?
    private var input: InputViewController?
    
    private var firstTime = true
    private var previousKeyboardOverlap: CGFloat = 0
    
    override var canBecomeFirstResponder: Bool { true }
    override var inputAccessoryViewController: UIInputViewController? { accessory }
    
    static func instantiate(
        @ViewBuilder contentView: @escaping () -> any View,
        @ViewBuilder accessoryView: @escaping (UITextDocumentProxy, InputViewProxy) -> any View,
        @ViewBuilder inputView: @escaping (UITextDocumentProxy, InputViewProxy) -> any View
    ) -> ChatViewController? {
        let storyboard = UIStoryboard(name: "ChatViewStoryboard", bundle: nil)
        return storyboard.instantiateViewController(identifier: "ChatViewController") { coder in
            ChatViewController(
                coder: coder,
                contentView: contentView,
                accessoryView: accessoryView,
                inputView: inputView
            )
        }
    }
    
    private init?(
        coder: NSCoder,
        contentView: @escaping () -> any View,
        accessoryView: @escaping (UITextDocumentProxy, InputViewProxy) -> any View,
        inputView: @escaping (UITextDocumentProxy, InputViewProxy) -> any View
    ) {
        contentViewBuilder = { AnyView(contentView()) }
        accessoryViewBuilder = { AnyView(accessoryView($0, $1)) }
        inputViewBuilder = { AnyView(inputView($0, $1)) }
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("use init?(coder:contentView:accessoryView:inputView:) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        accessory = InputViewController.instantiate(selfSizing: true, content: accessoryViewBuilder)
        input = InputViewController.instantiate(selfSizing: false, content: inputViewBuilder)
        accessory?.input = input
        
        DispatchQueue.main.async {
            self.becomeFirstResponder()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardFrameChanged), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func updateContent(
        contentView: @escaping () -> any View,
        accessoryView: @escaping (UITextDocumentProxy, InputViewProxy) -> any View,
        inputView: @escaping (UITextDocumentProxy, InputViewProxy) -> any View
    ) {
        contentViewBuilder = { AnyView(contentView()) }
        accessoryViewBuilder = { AnyView(accessoryView($0, $1)) }
        inputViewBuilder = { AnyView(inputView($0, $1)) }
        
        hostingController?.rootView = contentViewBuilder()
        accessory?.updateContent(accessoryViewBuilder)
        input?.updateContent(inputViewBuilder)
    }

    @IBSegueAction func showHostingController(_ coder: NSCoder) -> UIViewController? {
        let hostingController = UIHostingController(coder: coder, rootView: contentViewBuilder())
        hostingController?.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController?.sizingOptions = .intrinsicContentSize
        hostingController?.safeAreaRegions = []
        self.hostingController = hostingController
        return hostingController
    }
    
    @objc func keyboardFrameChanged(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        let convertedFrameEnd = view.convert(keyboardFrameEnd, from: view.window)
        guard convertedFrameEnd.origin.y != view.frame.maxY else { return }
        
        let keyboardOverlap = scrollView.frame.maxY - convertedFrameEnd.origin.y - scrollView.safeAreaInsets.bottom
        
        scrollView.contentInset.bottom = keyboardOverlap
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardOverlap
        
        let updateScrollView = {
            self.view.layoutIfNeeded()
            let offset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.adjustedContentInset.bottom)
            if offset.y < self.scrollView.contentOffset.y || self.previousKeyboardOverlap < keyboardOverlap {
                self.scrollView.setContentOffset(offset, animated: false)
            }
        }
        
        if firstTime {
            firstTime = false
            UIView.performWithoutAnimation(updateScrollView)
        } else {
            updateScrollView()
        }
        
        previousKeyboardOverlap = keyboardOverlap
    }
}
