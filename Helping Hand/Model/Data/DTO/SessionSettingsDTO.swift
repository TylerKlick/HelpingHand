//
//  SessionSettingsDTO.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/23/25.
//

import Foundation

struct SessionSettingsDTO {
    let eSMGSampleRate: Double
    let imuSampleRate:  Double
    let windowSize:     Int
    let windowType:     String
    let overlapRatio:   Float
    let channelMap:     [Int]
}
