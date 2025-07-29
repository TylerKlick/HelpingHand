//
//  Session.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/24/25.
//
//

import Foundation
import SwiftData

@Model public class Session {
    @Attribute(.unique) var sessionID: UUID
    var startTime: Date
    var endTime: Date
    @Relationship(deleteRule: .cascade) var frames: [DataFrame]?
    var settings: SessionSettings?
    
    public init(endTime: Date, mode: String, sessionID: UUID, startTime: Date) {
        self.endTime = endTime
        self.sessionID = sessionID
        self.startTime = startTime
    }
    
}
