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
    var endTime_: Date
    var sessionID_: UUID
    var startTime_: Date
    @Relationship(deleteRule: .cascade) var frames: [DataFrame]?
    @Relationship(deleteRule: .cascade) var settings: SessionSettings?
    
    public init(endTime_: Date, mode_: String, sessionID_: UUID, startTime_: Date) {
        self.endTime_ = endTime_
        self.sessionID_ = sessionID_
        self.startTime_ = startTime_
    }
    
}
