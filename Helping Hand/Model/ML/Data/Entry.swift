//
//  Entry.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import Foundation

/// Data representation of sEMG and IMU data as well as metadata components
/// used in the storage and training of the CNN
struct Entry {
    var emg: [Int]
    var imu: [Int]
    var timestamp: Date
    var window_size: Int
    var userID: UUID
}
