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
    @Attribute(.unique) var frameID: UUID
    var imuData: Data
    var sEMGData: Data
    var timeStamp: Date
    var mode: Mode
    var label: String
    var session: Session?
    
    public init(label: String, mode: Mode, frameID: UUID, imuData: Data, sEMGData: Data, timeStamp: Date) {
        self.frameID = frameID
        self.imuData = imuData
        self.sEMGData = sEMGData
        self.timeStamp = timeStamp
        self.mode = mode
        self.label = label
    }
    
}
