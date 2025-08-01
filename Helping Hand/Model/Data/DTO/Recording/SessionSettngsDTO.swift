//
//  SessionSettngsDTO.swift
//  Helping Hand
//
//  Created by Tyler Klick on 8/1/25.
//

import Foundation

struct SessionSettingsDTO: Sendable {
    
    let fingerprint: String
    let sessions: [SessionDTO] = []
    
    // MARK: - Sampling Settings
    let channelMap: [SensorLocation : Int]
    let sEMGSampleRate: Double
    let imuSampleRate: Double
    
    // MARK: - Pre-processing Settings
    let overlapRatio: Float
    let windowSize: Int32
    let windowType: WindowType = WindowType.hamming

}
