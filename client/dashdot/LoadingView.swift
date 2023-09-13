//
//  LoadingView.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-07-09.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("-.")
                .font(.custom("Dashdot-Regular", fixedSize: 64))
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}

#Preview {
    LoadingView()
}
