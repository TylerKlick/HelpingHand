//
//  Device.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/14/25.
//

import SwiftData
import Foundation
import CoreBluetooth
import FluentDTOMacro

/// Representation of Bluetooth Peripheral in static storage and at runtime
@FluentDTO
@Model
@Observable
final class Device: Identifiable{
    
    // MARK: - Parameters to save in storage
    @Attribute(.unique) private(set) var id: UUID
    @Attribute(.unique) private(set) var identifier: UUID
    private(set) var name: String
    private(set) var dateAdded: Date
    private(set) var lastSeen: Date
    
    // MARK: - Parameters only used at runtime (not saved)
    @FluentDTOIgnore @Transient var connectionState: DeviceConnectionState = DeviceConnectionState.disconnected
    @FluentDTOIgnore @Transient var validationTimer: Timer?
    @FluentDTOIgnore @Transient var responseTimer: Timer?

    init(name: String? = nil, identifier: UUID, dateAdded: Date? = nil, lastSeen: Date? = nil) {
        self.id = UUID()
        self.name = name ?? "Unknown Device"
        self.identifier = identifier
        self.dateAdded = dateAdded ?? Date()
        self.lastSeen = lastSeen ?? Date()
        self.connectionState = .disconnected
    }
    
    convenience init(_ peripheral: CBPeripheral) {
        self.init(name: peripheral.name, identifier: peripheral.identifier)
    }
    
//    convenience init(fromDTO deviceDTO: DeviceDTO) {
//        self.init(name: deviceDTO.name, identifier: deviceDTO.identifier, dateAdded: deviceDTO.dateAdded, lastSeen: deviceDTO.lastSeen)
//    }
    
    public func updateLastSeen() -> Void {
        self.lastSeen = Date()
    }
}
