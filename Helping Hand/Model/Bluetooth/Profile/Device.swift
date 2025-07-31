//
//  Device.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/14/25.
//

import SwiftData
import Foundation
import CoreBluetooth

/// Representation of Bluetooth Peripheral in static storage and at runtime
@Model
class Device: Identifiable, ObservableObject {
    
    // MARK: - Parameters to save in storage
    @Attribute(.unique) private(set) var id: UUID
    @Attribute(.unique) private(set) var identifier: UUID
    private(set) var name: String
    private(set) var dateAdded: Date
    private(set) var lastSeen: Date
    
    // MARK: - Parameters only used at runtime (not saved)
    @Transient @Published var connectionState: DeviceConnectionState = DeviceConnectionState.disconnected
    @Transient var validationTimer: Timer?
    @Transient var responseTimer: Timer?

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
    
    public func updateLastSeen() -> Void {
        self.lastSeen = Date()
    }
}
