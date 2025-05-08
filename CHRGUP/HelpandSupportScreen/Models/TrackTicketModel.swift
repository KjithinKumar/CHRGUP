//
//  TrackTicketModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 01/05/25.
//

import Foundation

struct TrackTicketResponseModel: Decodable {
    var success : Bool
    var message : String?
    var data : [TicketModel]?
}


