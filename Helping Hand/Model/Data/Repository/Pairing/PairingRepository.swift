//
//  PairingRepository.swift
//  Helping Hand
//
//  Created by Tyler Klick on 8/1/25.
//

import Foundation
import SwiftData

protocol PairingRepository: Sendable {
    
    /// Get a list of all paired devices
    func getAllPairings() async throws -> [Device]
    
    /// Add a device to the paired list
    func pair(_ device: Device) async throws -> Void
    
    /// Remove a device from the paired list
    func unpair() async throws -> Void
    
    /// Check if a device has already been paired
    func isPaired(identifier: UUID) async throws -> Bool
    
    /// Get a paired device by it's identifier
    func getPairedDevice(identifier: UUID) async throws -> Bool
}
