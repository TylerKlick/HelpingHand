//
//  SessionSettings.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/24/25.
//
//

import Foundation
import SwiftData

@Model public class SessionSettings {
    var channelMap_: [String : Int] = ["forearm" : 0]
    var sEMGSampleRate_: Double = 1000.0
    var imuSampleRate_: Double = 1000.0
    var overlapRatio_: Float = 0.5
    var windowSize_: Int32 = 32
    var windowType_: String = "hamming"
    var session: [Session]?

    public init(channelMap_: [String : Int], windowType_: String) {
        self.channelMap_ = channelMap_
        self.windowType_ = windowType_
    }
}
