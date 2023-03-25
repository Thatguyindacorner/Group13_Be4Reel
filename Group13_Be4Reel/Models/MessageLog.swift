//
//  MessageLog.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-25.
//

import Foundation
import FirebaseFirestoreSwift

class MessageLog: Codable{
    @DocumentID var id: String? //referenced in both User files as identifier
    
    var log: [[String: String]] = [] //ordered list of senderID: message (oldest first)
}

