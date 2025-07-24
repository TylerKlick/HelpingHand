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
    var frameID_: UUID
    var imuData_: Data
    var sEMGData_: Data
    var timeStamp_: Date
    var mode_: Mode
    var label_: String
    var session: Session?
    
    public init(label_: String, mode_: Mode, frameID_: UUID, imuData_: Data, sEMGData_: Data, timeStamp_: Date) {
        self.frameID_ = frameID_
        self.imuData_ = imuData_
        self.sEMGData_ = sEMGData_
        self.timeStamp_ = timeStamp_
        self.mode_ = mode_
        self.label_ = label_
    }
    
}
