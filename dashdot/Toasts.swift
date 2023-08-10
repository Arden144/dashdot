//
//  Toasts.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-07-07.
//

import SwiftUI
import Observation
import OSLog

struct Toast {
    let id: UUID
    var title: String
    var desc: String
    var persistent: Bool
    var image: AnyView
    
    init(title: String, desc: String, persistent: Bool = false, @ViewBuilder image: () -> some View = { EmptyView() }) {
        self.id = UUID()
        self.title = title
        self.desc = desc
        self.persistent = persistent
        self.image = AnyView(image())
    }
}

extension Toast: Equatable {
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.desc == rhs.desc
    }
}

extension Toast: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(desc)
    }
}

@Observable class ToastManager {
    private static let logger = Logger(subsystem: "com.ardensinclair.dashdot", category: "ToastManager")
    static let shared = ToastManager()
    
    private(set) var toasts: [Toast]
    
    private init() {
        self.toasts = []
    }
    
    func add(_ toast: Toast) {
        Self.logger.info("Displaying toast: \(toast.title, privacy: .public) - \(toast.desc, privacy: .public)")
        withAnimation(.snappy) {
            toasts.append(toast)
        }
    }
    
    func remove(_ toast: Toast) {
        if let index = toasts.firstIndex(of: toast) {
            Self.logger.info("Dismissing toast: \(toast.title, privacy: .public) - \(toast.desc, privacy: .public)")
            let _ = withAnimation(.snappy) {
                toasts.remove(at: index)
            }
        }
    }
}

struct ToastView: View {
    var toast: Toast
    var onDismiss: (() -> ())?
    
    @State private var dragDistance: CGFloat = 0
    // TODO: This magic value is based off of where the toast is displayed currently
    @State private var verticalOffset: CGFloat = 96
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            toast.image
                .scaledToFit()
                .frame(width: 24, height: 24)
            Spacer()
            VStack(alignment: .center, spacing: 1) {
                Text(toast.title)
                Text(toast.desc)
                    .foregroundStyle(.tertiary)
            }
            .font(.footnote.weight(.semibold))
            Spacer()
            Button(action: { onDismiss?() }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .foregroundStyle(.blue, .bar)
                    .fontWeight(.light)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .fixedSize()
        .background(.regularMaterial, in: .rect(cornerRadius: .infinity))
        .shadow(radius: 24)
        .offset(y: dragDistance)
        .animation(.interactiveSpring(duration: 0.3), value: dragDistance)
        .background {
            GeometryReader { proxy in
                Color.clear.onChange(of: proxy.frame(in: .global), initial: true) { _, frame in
                    verticalOffset = frame.maxY
                }
            }
        }
        .transition(.offset(y: -verticalOffset))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.height <= 0 {
                        dragDistance = gesture.translation.height / 2
                    } else {
                        dragDistance = 0
                    }
                }
                .onEnded { gesture in
                    dragDistance = 0
                    if gesture.translation.height <= -(verticalOffset / 2) {
                        onDismiss?()
                    }
                }
        )
        .id(toast)
        .task(id: toast) {
            if toast.persistent { return }
            guard let onDismiss else { return }
            do {
                try await Task.sleep(for: .seconds(5))
                onDismiss()
            } catch {}
        }
    }
}

#Preview {
    let toast = Toast(title: "Arden's AirPods Pro", desc: "Moved to Mac") {
        Image(systemName: "airpodspro")
    }
    
    return ToastView(toast: toast)
}
