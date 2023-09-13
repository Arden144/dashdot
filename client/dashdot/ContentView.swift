//
//  ContentView.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-07-08.
//

import SwiftUI
import GRDBQuery

struct ContentView: View {
    @Bindable private var sessionManager = SessionManager.shared
    @Query<User.Request> private var user: User?
    
    init(userID: Int?) {
        _user = Query(constant: .init(userID: userID), in: \.db)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user {
                    HomeView(user: user)
                } else {
                    LoadingView()
                }
            }
            .frame(maxHeight: .infinity)
            .sheet(isPresented: $sessionManager.session.readonlyMap { $0 == nil }) {
                LoginView()
                    .interactiveDismissDisabled()
            }
        }
        .overlay(alignment: .top) {
            if let toast = ToastManager.shared.toasts.last {
                ToastView(toast: toast, onDismiss: {
                    ToastManager.shared.remove(toast)
                })
            }
        }
    }
}

#Preview {
    let toast1 = Toast(title: "Arden's AirPods Pro", desc: "Moved to Mac") {
        Image(systemName: "airpodspro")
    }
    
    let toast2 = Toast(title: "Arden's AirPods Max", desc: "Moved to iPad") {
        Image(systemName: "airpodsmax")
    }
    
    @State var sessionManager = SessionManager.shared
    sessionManager.session = Session(accessToken: "", refreshToken: "", userID: Int(Previews.users[0].id))
    
    @State var toastManager = ToastManager.shared
    toastManager.add(toast1)
    toastManager.add(toast2)
    
    return ContentView(userID: sessionManager.session?.userID)
        .environment(sessionManager)
        .environment(toastManager)
}
