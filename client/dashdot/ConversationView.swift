//
//  ConversationView.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-04-03.
//

import SwiftUI
import GRDB
import GRDBQuery
import OSLog

struct Bubble: View {
    let user: User
    let msg: Message
    
    var body: some View {
        if msg.authorId == user.id {
            Text(msg.body)
                .id(msg.id)
                .padding(.horizontal)
                .padding(.vertical, 12.0)
                .foregroundStyle(.white)
                .movingGradientBackground(in: .rect(cornerRadius: 24))
                .font(.custom("Dashdot-Regular", size: 16, relativeTo: .body))
                .containerRelativeFrame(.horizontal, count: 3, span: 2, spacing: 0, alignment: .trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            Text(msg.body)
                .id(msg.id)
                .padding(.horizontal)
                .padding(.vertical, 12.0)
                .foregroundStyle(.primary)
                .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 24))
                .font(.custom("Dashdot-Regular", size: 16, relativeTo: .body))
                .containerRelativeFrame(.horizontal, count: 3, span: 2, spacing: 0, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ConversationView: View {
    var user: User
    var conversation: DetailedConversation
    
    @Query<DetailedMessage.Request> private var messages: [DetailedMessage]
    
    init(user: User, conversation: DetailedConversation) {
        self.user = user
        self.conversation = conversation
        _messages = Query(constant: .init(conversation: conversation), in: \.db)
    }
    
    var body: some View {
        VStack {
            ForEach(messages) { message in
                Bubble(user: user, msg: message.message)
            }
        }
        .padding()
    }
}

#Preview {
    let conversation = try! Database.preview.read { db in
        try DetailedConversation.request.fetchOne(db)!
    }
    
    return NavigationStack {
        ConversationView(user: Previews.users[0], conversation: conversation)
    }
}

struct MorseTextField: View {
    private static let client = Api_ChatClient.shared
    private static let logger = Logger(subsystem: "com.ardensinclair.dashdot", category: "MorseTextField")
    
    var user: User
    var conversation: DetailedConversation
    var inputProxy: InputViewProxy
    
    @State private var text = ""
    
    func sendMessage(text: String) async {
        var request = Msg_NewMsg()
        request.userID = user.id
        request.chatID = conversation.id
        request.text = text
        
        Self.logger.info("Sending a message")
        
        let response = await Self.client.sendMsg(request: request)
        
        switch response.result {
        case .success(let message):
            Self.logger.notice("Message sent successfully: \(message.debugDescription)")
        case .failure(let error):
            Self.logger.error("Message failed to send: \(error)")
            ToastManager.shared.add(Toast(title: "Failed to send", desc: "Try again later") {
                Image(systemName: "message.badge")
                    .foregroundStyle(.red)
            })
        }
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            TextField(text: $text, axis: .vertical) {
                Text("Message")
            }
            .textFieldStyle(.plain)
            .lineLimit(4)
            .font(.custom("Dashdot-Regular", size: 16, relativeTo: .body))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
            .padding(.vertical, 8)
            Button {
                if text == "" { return }
                Task {
                    await sendMessage(text: text)
                    text = ""
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .padding(4)
            }

        }
        .background(.primary.opacity(0.2))
        .background(.ultraThickMaterial, in: .rect(cornerRadius: 20))
        .padding()
        .background(.ultraThinMaterial)
        .onChange(of: text) {
            inputProxy.updateLayout()
        }
    }
}
