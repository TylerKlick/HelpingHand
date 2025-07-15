//
//  Device.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/14/25.
//

import Foundation
import CoreBluetooth

// MARK: - Paired Device Info
struct Device: Codable, Identifiable {
    let id: UUID
    let name: String
    let identifier: UUID
    let dateAdded: Date
    var lastSeen: Date
    
    init(peripheral: CBPeripheral) {
        self.id = UUID()
        self.name = peripheral.name ?? "Unknown Device"
        self.identifier = peripheral.identifier
        self.dateAdded = Date()
        self.lastSeen = Date()
    }
}
