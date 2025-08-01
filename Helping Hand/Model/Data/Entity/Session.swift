//
//  Session.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/24/25.
//
//

import Foundation
import SwiftData

/**
 Representation of User App Session, linking SessionSettings metadata with collected/processed features
   for improved storage and readability
 
    - Entity Relationship
       - SessionSettings: Many-to-One -- Multiple Sessions can share the same SessionSettings, but each may only have one
       - DataFrame: One-to-Many -- A single Session can have multiple DataFrames, but each dataframe may only have one Session.
*/
@Model public class Session {
    @Attribute(.unique) private(set) var sessionID: UUID
    @Relationship(deleteRule: .cascade) private(set) var frames: [DataFrame]?
    private(set) var settings: SessionSettings?
    private(set) var startTime: Date
    private(set) var endTime: Date?
    
    public init(_ sessionSettings: SessionSettings) {
        self.sessionID = UUID()
        self.settings = sessionSettings
        self.startTime = Date()
    }
    
    public func endSession() -> Void {
        self.endTime = Date()
    }
    
    public func addFrame(_ frame: DataFrame) -> Void {
        if self.frames == nil {
            self.frames = [frame]
        } else if !self.frames!.contains(where: { $0.frameID == frame.frameID }) {
            self.frames!.append(frame)
        }
    }
    
    public func removeFrame(frameID: UUID) -> Void {
        self.frames?.removeAll(where: { $0.frameID == frameID })
    }
}
