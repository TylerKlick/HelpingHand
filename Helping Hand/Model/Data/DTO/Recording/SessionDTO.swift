//
//  SessionDTO.swift
//  Helping Hand
//
//  Created by Tyler Klick on 8/1/25.
//

import Foundation

struct SessionDTO: Sendable {
    let sessionID: UUID
    let frames: [DataFrameDTO]
    let settings: SessionSettingsDTO
    let startTime: Date
    let endTime: Date?
}
