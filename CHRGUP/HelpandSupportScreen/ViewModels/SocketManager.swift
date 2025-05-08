//
//  SocketManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 03/05/25.
//

import Foundation
import SocketIO

class ChatSocketManager {
    static let shared = ChatSocketManager()

    private var manager: SocketManager!
    var socket: SocketIOClient!

    private init() {}
    
    private var ticketId: String = ""
    private var userId: String = ""
    private let senderModel = "User"

    func establishConnection(ticketId: String, userId: String) {
        self.ticketId = ticketId
        self.userId = userId
        
        if socket != nil { return }
        
        let url = URL(string: URLs.socketUrl)!
        manager = SocketManager(socketURL: url, config: [.log(true), .forceWebsockets(true), .forceNew(true),.compress, .selfSigned(false), .secure(true)])
        socket = manager?.defaultSocket
        
        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            self?.joinTicket()
        }
        socket?.connect()
    }
    private func joinTicket() {
        socket?.emitWithAck("joinTicket", ticketId, userId).timingOut(after: 5) { _ in
            
        }
    }

    func closeConnection() {
        socket.disconnect()
        socket = nil
        manager = nil
    }

    func sendMessage(_ message: String) {
        socket?.emitWithAck("sendMessage", ticketId, userId, senderModel, message).timingOut(after: 5) { _ in
        }
    }

    func observeMessages(completion: @escaping (_ message: MessageModel) -> Void) {
        socket?.on("receiveMessage") { data, _ in
                do {
                    guard let rawData = data.first else {return}
                    let jsonData = try JSONSerialization.data(withJSONObject: rawData)
                    let message = try JSONDecoder().decode(MessageModel.self, from: jsonData)
                    completion(message)
                } catch {
                    print("Failed to decode message: \(error)")
                }
            }
    }
}
