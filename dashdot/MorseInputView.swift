//
//  MorseInputView.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-06.
//

import SwiftUI
import UIKit

class MorseInputViewController: UIInputViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        inputView = UIMorseInputView(proxy: textDocumentProxy)
    }
}

private final class UIMorseInputView: UIInputView {
    init(proxy: UITextDocumentProxy) {
        super.init(frame: .init(x: 0, y: 0, width: 0, height: 0), inputViewStyle: .keyboard)
        translatesAutoresizingMaskIntoConstraints = false
        
        let hostingController = UIHostingController(rootView: MorseInputView(proxy: proxy))
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        
        let constraints = [
            topAnchor.constraint(equalTo: hostingController.view.topAnchor),
            leftAnchor.constraint(equalTo: hostingController.view.leftAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: rightAnchor)
        ]
        
        constraints.forEach { $0.priority = .required }
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private enum Feedback {
    case dot
    case dash
    case none
}

struct MorseInputView: View {
    var proxy: UITextDocumentProxy?
    @Environment(\.colorScheme) private var colorScheme
    @State private var feedback: Feedback = .none
    
    var body: some View {
        VStack(spacing: 16.0) {
            HStack(spacing: 16.0) {
                Button {
                    proxy?.insertText(".")
                } label: {
                    Circle()
                        .fill(colorScheme == .dark ? .white : .black)
                        .frame(width: 12.0, height: 12.0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(16.0)
                }
                ._onButtonGesture { pressed in
                    feedback = pressed ? .dot : .none
                } perform: {}
                Button {
                    proxy?.insertText("-")
                } label: {
                    RoundedRectangle(cornerRadius: 12.0)
                        .fill(colorScheme == .dark ? .white : .black)
                        .frame(width: 36.0, height: 12.0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(16.0)
                }
                ._onButtonGesture { pressed in
                    feedback = pressed ? .dash : .none
                } perform: {}
            }
            HStack(spacing: 16.0) {
                Button {
                    proxy?.insertText("/")
                } label: {
                    Text("/")
                        .font(.custom("Dashdot-Regular", size: 16.0))
                        .frame(width: 50.0, height: 50.0)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12.0)
                }
                Button {
                    proxy?.insertText(" ")
                } label: {
                    Image(systemName: "space")
                        .fontWeight(.bold)
                        .frame(height: 50.0)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12.0)
                }
                Button {
                    proxy?.deleteBackward()
                } label: {
                    Image(systemName: "delete.left")
                        .fontWeight(.semibold)
                        .frame(width: 50.0, height: 50.0)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12.0)
                }
                .buttonRepeatBehavior(.enabled)
            }
        }
        .padding()
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .sensoryFeedback(trigger: feedback) { _, feedback in
            switch feedback {
            case .dash:
                return .impact(weight: .medium)
            case .dot:
                return .impact(weight: .light)
            case .none:
                return .none
            }
        }
    }
}

#Preview {
    MorseInputView(proxy: nil)
}
