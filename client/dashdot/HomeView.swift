//
//  HomeView.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-04-08.
//

import SwiftUI
import GRDBQuery
import OSLog

private let notificationLogger = Logger(subsystem: "com.ardensinclair.dashdot", category: "Notifications")

func getChatName(users: [User], myself: User) -> String {
    if users.count <= 1 {
        return users.first?.name ?? "Nobody"
    } else {
        return users
            .filter { $0.id != myself.id }
            .map { $0.name }
            .joined(separator: ", ")
    }
}

struct HomeView: View {
    var user: User
    
    @Query(DetailedConversation.Request())
    private var conversations: [DetailedConversation]
    
    @State private var settingsOpen = false
    
    var body: some View {
        List(conversations) { conversation in
            NavigationLink {
                ChatView {
                    ConversationView(user: user, conversation: conversation)
                } accessoryView: { documentProxy, inputProxy in
                    MorseTextField(user: user, conversation: conversation, inputProxy: inputProxy)
                } inputView: { documentProxy, inputProxy in
                    MorseInputView(proxy: documentProxy)
                }
                .movingGradientContainer(colors: [
                    .init(red: 34/255, green: 146/255, blue: 245/255),
                    .init(red: 0, green: 135/255, blue: 254/255)
                ])
                .navigationTitle(getChatName(users: conversation.members, myself: user))
            } label: {
                VStack(alignment: .leading) {
                    Text(getChatName(users: conversation.members, myself: user))
                        .font(.body.bold())
                    if let message = conversation.latestMessage {
                        Text(message.body)
                            .lineLimit(2)
                            .font(.custom("Dashdot-Regular", size: 16, relativeTo: .body))
                    }
                }
                .padding(.vertical, 8.0)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        let center = UNUserNotificationCenter.current()
                        do {
                            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                            guard granted else { return }
                            
                            let content = UNMutableNotificationContent()
                            content.title = "This is a test"
                            content.body = "How are you doing?"
                            
                            let date = Calendar.current.date(byAdding: .second, value: 10, to: .now)!
                            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                            let identifier = UUID().uuidString
                            
                            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                            
                            try await center.add(request)
                        } catch {
                            notificationLogger.error("Notification request failed: \(error, privacy: .public)")
                        }
                    }
                } label: {
                    Image(systemName: "app.badge")
                }
                
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    ToastManager.shared.add(Toast(title: "This is a test", desc: "How are you doing?") {
                        Image(systemName: "arrow.up.and.down.and.sparkles")
                    })
                } label: {
                    Image(systemName: "bell.badge")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    settingsOpen = true
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $settingsOpen) {
            NavigationStack {
                SettingsView()
            }
        }
        .navigationTitle("Chats")
    }
}

#Preview {
    @State var sessionManager = SessionManager.shared
    sessionManager.session = .preview
    
    return HomeView(user: Previews.users[0])
        .environment(sessionManager)
}
