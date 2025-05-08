//
//  TrackTicketViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 01/05/25.
//

import Foundation
protocol TrackTicketViewModelInterface {
    var userTickets : [TicketModel]? { get set }
    func getAllTickets(completeion: @escaping (Result<TrackTicketResponseModel, Error>) -> Void)
    func getAllMessages(ticketId : String,completion: @escaping(Result<MessageResponseModel, Error>) -> Void)
    var userMessages : [MessageModel]? { get set }
    var groupedMessages: [(date: String, messages: [MessageModel])] {get set}
    func appendNewMessage(_ newMessage: MessageModel)
}

class TrackTicketViewModel: TrackTicketViewModelInterface {
    var networkManager: NetworkManagerProtocol?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    var userTickets : [TicketModel]?
    var userMessages : [MessageModel]?
    var groupedMessages: [(date: String, messages: [MessageModel])] = []

    func groupMessagesByDate(_ messages: [MessageModel]) {
        let groupedDict = Dictionary(grouping: messages) { message in
            return formattedDate(for: message.createdAt)
        }

        let sorted = groupedDict
            .sorted(by: { parseDisplayDate($0.key) < parseDisplayDate($1.key) }) // sort date groups correctly
            .map { (key, value) in
                let sortedMessages = value.sorted {
                    parseISODate($0.createdAt) < parseISODate($1.createdAt)
                }
                return (date: key, messages: sortedMessages)
            }

        groupedMessages = sorted
    }

    func formattedDate(for dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: dateStr) else { return "" }

        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMMM yyyy"
            return outputFormatter.string(from: date)
        }
    }
    private func parseISODate(_ dateStr: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateStr) ?? Date.distantPast
    }
    private func parseDisplayDate(_ displayStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        
        if displayStr == "Today" {
            return Calendar.current.startOfDay(for: Date())
        } else if displayStr == "Yesterday" {
            return Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? .distantPast
        } else {
            return formatter.date(from: displayStr) ?? .distantPast
        }
    }
    func appendNewMessage(_ newMessage: MessageModel) {
        let newMessageDate = formattedDate(for: newMessage.createdAt)

        // Try to find index of existing group
        if let index = groupedMessages.firstIndex(where: { $0.date == newMessageDate }) {
            // Append and sort the group
            groupedMessages[index].messages.append(newMessage)
            groupedMessages[index].messages.sort {
                parseISODate($0.createdAt) < parseISODate($1.createdAt)
            }
        } else {
            // Create a new group and insert it in sorted order
            let newGroup = (date: newMessageDate, messages: [newMessage])
            groupedMessages.append(newGroup)
            groupedMessages.sort {
                parseDisplayDate($0.date) < parseDisplayDate($1.date)
            }
        }
    }
    
    func getAllTickets(completeion: @escaping (Result<TrackTicketResponseModel, Error>) -> Void) {
        let url = URLs.getTicketUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return}
        let headers = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: headers){
            networkManager?.request(request, decodeTo: TrackTicketResponseModel.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if response.success {
                        if let tickets = response.data {
                            self.userTickets = tickets
                        }
                    }
                    completeion(.success(response))
                case .failure(let error):
                    completeion(.failure(error))
                }
            }
        }
    }
    func getAllMessages(ticketId : String,completion: @escaping(Result<MessageResponseModel, Error>) -> Void){
        let url = URLs.getAllMessagesUrl(ticketId: ticketId)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return}
        let headers = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: headers){
            networkManager?.request(request, decodeTo: MessageResponseModel.self) { [weak self] result in
                guard let self = self else { return }
                switch result{
                case .success(let response):
                    if response.status {
                        self.userMessages = response.messages
                        if let messages = response.messages{
                            self.groupMessagesByDate(messages)
                        }
                    }
                    completion(.success(response))
                case.failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
