//
//  MovingGradient.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-07-18.
//

import SwiftUI
import Observation

@Observable
private final class MovingGradientData {
    var colors: [Color] = []
    var parentHeight: CGFloat = 0
    
    init(colors: [Color] = [], parentHeight: CGFloat = 0) {
        self.colors = colors
        self.parentHeight = parentHeight
    }
}

private struct MovingGradientContainer<V: View>: View {
    var content: V
    
    @State private var data: MovingGradientData
    
    init(colors: [Color], content: V) {
        self.content = content
        self._data = State(wrappedValue: MovingGradientData(colors: colors))
    }
    
    var body: some View {
        content
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onChange(of: proxy.size.height, initial: true) {
                            data.parentHeight = proxy.size.height
                        }
                }
            }
            .environment(data)
    }
}

private struct MovingGradientBackground<S: Shape>: View {
    @Environment(MovingGradientData.self) private var data
    var shape: S
    
    private func startPoint(_ geometry: GeometryProxy) -> UnitPoint {
        let frame = geometry.frame(in: .global)
        let startOffset = -frame.minY / frame.height
        return UnitPoint(x: 0, y: startOffset)
    }
    
    private func endPoint(_ geometry: GeometryProxy) -> UnitPoint {
        let frame = geometry.frame(in: .global)
        let endOffset = (data.parentHeight - frame.maxY) / frame.height
        return UnitPoint(x: 0, y: endOffset + 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            shape.fill(
                LinearGradient(
                    colors: data.colors,
                    startPoint: startPoint(geometry),
                    endPoint: endPoint(geometry)
                )
            )
        }
    }
}

extension View {
    func movingGradientContainer(colors: [Color]) -> some View {
        MovingGradientContainer(colors: colors, content: self)
    }
}

extension View {
    func movingGradientBackground(in shape: some Shape) -> some View {
        self.background {
            MovingGradientBackground(shape: shape)
        }
    }
}
