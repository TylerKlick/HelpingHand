//
//  DataFrameDTO.swift
//  Helping Hand
//
//  Created by Tyler Klick on 8/1/25.
//

import Foundation

struct DataFrameDTO: Sendable {
    let frameID: UUID
    let session: SessionDTO
    let imuData: Data
    let sEMGData: Data
    let timeStamp: Date
    let mode: Mode = Mode.inference
    let label: String
}
