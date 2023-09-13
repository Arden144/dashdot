//
//  SettingsView.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("devEnvironment") private var devEnvironment = false
    
    var body: some View {
        Form {
            Section("Development") {
                Toggle("Use development server", isOn: $devEnvironment)
            }
            Section {
                Button(role: .destructive) {
                    withAnimation {
                        dismiss()
                    } completion: {
                        SessionManager.shared.session = nil
                    }
                } label: {
                    Text("Log out")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @State var sessionManager = SessionManager.shared
    
    sessionManager.session = .preview
    
    return NavigationStack {
        SettingsView()
            .environment(sessionManager)
    }
}
