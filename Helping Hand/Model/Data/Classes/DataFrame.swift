//
//  DataFrame.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/24/25.
//
//

import Foundation
import SwiftData

@Model public class DataFrame {
    @Attribute(.unique) private(set) var frameID: UUID
    @Relationship(inverse: \Session.frames) private(set) var session: Session?
    private(set) var imuData: Data
    private(set) var sEMGData: Data
    private(set) var timeStamp: Date
    private(set) var mode: Mode = Mode.inference
    private(set) var label: String
    
    public init(session: Session, label: String, mode: Mode, imuData: Data, sEMGData: Data, timeStamp: Date) {
        self.frameID = UUID()
        self.session = session
        self.imuData = imuData
        self.sEMGData = sEMGData
        self.timeStamp = timeStamp
        self.mode = mode
        self.label = label
    }
}
