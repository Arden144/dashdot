//
//  BindingExt.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-27.
//

import SwiftUI

extension Binding {
    func readonlyMap<R>(fn: @escaping (Value) -> R) -> Binding<R> {
        Binding<R>(get: { fn(wrappedValue) }, set: { _ in })
    }
}
