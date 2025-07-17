//
//  Device.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/14/25.
//

import Foundation
import CoreBluetooth

/// Representation of Bluetooth Peripheral in static storage and at runtime
class Device: Codable, Identifiable, ObservableObject {
    
    // MARK: - Parameters to save in storage
    let id: UUID
    let name: String
    let identifier: UUID
    let dateAdded: Date
    var lastSeen: Date
    
    // MARK: - Parameters only used at runtime (not saved)
    @Published var connectionState: DeviceConnectionState = .disconnected
    var validationTimer: Timer?
    var responseTimer: Timer?
    
    /// Indicate which parameters we want in the Encoded data saved
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case identifier
        case dateAdded
        case lastSeen
    }

    init(name: String? = nil, identifier: UUID) {
        self.id = UUID()
        self.name = name ?? "Unknown Device"
        self.identifier = identifier
        self.dateAdded = Date()
        self.lastSeen = Date()
        self.connectionState = .disconnected
    }
    
    convenience init(_ peripheral: CBPeripheral) {
        self.init(name: peripheral.name, identifier: peripheral.identifier)
    }
}
