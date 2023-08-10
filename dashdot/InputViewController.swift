//
//  EpicScrollView.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-08-04.
//

import UIKit
import SwiftUI

class InputViewProxy {
    private weak var inputViewController: InputViewController?
    
    fileprivate init(_ inputViewController: InputViewController) {
        self.inputViewController = inputViewController
    }
    
    func updateLayout() {
        inputViewController?.hostingController?.view.invalidateIntrinsicContentSize()
    }
}

class InputViewController: UIInputViewController {
    @IBOutlet private var mountedInputView: UIInputView!
    
    fileprivate weak var hostingController: UIHostingController<AnyView>?
    var input: InputViewController?
    
    private let selfSizing: Bool
    private var contentBuilder: (UITextDocumentProxy, InputViewProxy) -> AnyView
    
    override var inputViewController: UIInputViewController? { input }
    
    static func instantiate(
        selfSizing: Bool,
        @ViewBuilder content: @escaping (UITextDocumentProxy, InputViewProxy) -> any View
    ) -> InputViewController {
        let storyboard = UIStoryboard(name: "InputViewStoryboard", bundle: nil)
        return storyboard.instantiateViewController(identifier: "InputViewController") { coder in
            InputViewController(
                coder: coder,
                selfSizing: selfSizing,
                content: content
            )
        }
    }
    
    private init?(
        coder: NSCoder,
        selfSizing: Bool,
        content: @escaping (UITextDocumentProxy, InputViewProxy) -> any View
    ) {
        self.selfSizing = selfSizing
        contentBuilder = { AnyView(content($0, $1)) }
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("use init(coder:selfSizing:content:) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mountedInputView.removeFromSuperview()
        mountedInputView.allowsSelfSizing = selfSizing
        inputView = mountedInputView
    }
    
    func updateContent(_ content: @escaping (UITextDocumentProxy, InputViewProxy) -> any View) {
        contentBuilder = { AnyView(content($0, $1)) }
        hostingController?.rootView = contentBuilder(textDocumentProxy, InputViewProxy(self))
    }
    
    @IBSegueAction func showHostingController(_ coder: NSCoder) -> UIViewController? {
        let hostingController = UIHostingController(coder: coder, rootView: contentBuilder(textDocumentProxy, InputViewProxy(self)))
        hostingController?.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController?.sizingOptions = .intrinsicContentSize
        hostingController?.safeAreaRegions = .container
        self.hostingController = hostingController
        return hostingController
    }
}
