////
////  MorseTextView.swift
////  dashdot
////
////  Created by Arden Sinclair on 2023-05-06.
////


import SwiftUI
import UIKit

private final class CustomUITextView: UITextView {
    private var _inputViewController: UIInputViewController?
    
    override var inputViewController: UIInputViewController? {
        get { _inputViewController }
        set { _inputViewController = newValue }
    }
}

extension UITextView {
    func lineCount() -> Int {
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var index = 0
        var numberOfLines = 0
        var lineRange = NSRange(location: NSNotFound, length: 0)

        while index < numberOfGlyphs {
          layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
          index = NSMaxRange(lineRange)
          numberOfLines += 1
        }
        
        return numberOfLines
    }
}

private let baseHeight: CGFloat = 18
private let uiFont: UIFont = UIFont.init(name: "Dashdot-Regular", size: baseHeight)!

private struct TextViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    @Environment(\.lineLimit) var lineLimit: Int?

    func makeUIView(context: Context) -> CustomUITextView {
        let uiView = CustomUITextView()
        uiView.delegate = context.coordinator
        uiView.inputViewController = MorseInputViewController()
        uiView.backgroundColor = .clear
        uiView.bounces = false
        uiView.font = uiFont
        return uiView
    }
    
    func updateUIView(_ uiView: CustomUITextView, context: Context) {
        uiView.text = text
        
        let newSize = uiView.sizeThatFits(.init(
            width: uiView.frame.width,
            height: .infinity
        ))
        
        let maxHeight: CGFloat
        
        if var lineLimit = lineLimit {
            if lineLimit < 1 {
                lineLimit = 1
            }
            
            maxHeight = ceil(baseHeight + (CGFloat(lineLimit) * uiFont.lineHeight))
        } else {
            maxHeight = .infinity
        }
        
        let newHeight = min(newSize.height, maxHeight)
        
        Task { @MainActor in
            height = newHeight
            uiView.bounces = newHeight == maxHeight
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
}

private final class Coordinator: NSObject, UITextViewDelegate {
    var text: Binding<String>
    
    init(text: Binding<String>) {
        self.text = text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        text.wrappedValue = textView.text
    }
}

struct MorseTextView: View {
    @Binding var text: String
    
    @State private var height: CGFloat = 0
    
    var body: some View {
        TextViewRepresentable(text: $text, height: $height)
            .font(.custom("Dashdot-Regular", size: 32.0))
            .frame(height: height)
    }
}
