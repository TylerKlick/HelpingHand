//
//  DevicePairingManager.swift
//  Helping Hand
//
//  Device pairing and persistence manager
//

import Combine
import Foundation
import os
import SwiftData

// MARK: - Device Pairing Manager
@ModelActor
final actor DevicePairingManager: PairingRepository {
    
    private let logger = Logger(subsystem: "com.helpinghand.app", category: "DevicePairingManager")
    
    func getAllPairings() async throws -> [Device] {
        let descriptor = FetchDescriptor<Device>(sortBy: [SortDescriptor(\.lastSeen, order: .reverse)])
        do {
            let pairedDevices = try modelContext.fetch(descriptor)
            logger.info("Successfully loaded \(pairedDevices.count) paired devices from SwiftData")
            return pairedDevices
        } catch {
            logger.error("Failed to fetch paired devices: \(error.localizedDescription)")
            return []
        }
    }

    func pair(_ device: Device) async throws {
        logger.info("Attempting to pair device: \(device.name) (ID: \(device.identifier))")

        guard try await isPaired(identifier: device.identifier) == false else {
            logger.warning("Device \(device.name) is already paired, skipping pairing")
            return
        }

        modelContext.insert(device)

        do {
            try modelContext.save()
            logger.info("Successfully paired device: \(device.name) (Internal ID: \(device.identifier.uuidString))")
        } catch {
            logger.error("Failed to save paired device: \(error.localizedDescription)")
            throw error
        }
    }

    func unpair() async throws {
        do {
            let allDevices = try modelContext.fetch(FetchDescriptor<Device>())
            for device in allDevices {
                modelContext.delete(device)
            }
            try modelContext.save()
            logger.info("All devices have been unpaired.")
        } catch {
            logger.error("Failed to unpair all devices: \(error.localizedDescription)")
            throw error
        }
    }

    func isPaired(identifier: UUID) async throws -> Bool {
        let descriptor = FetchDescriptor<Device>(predicate: #Predicate { $0.identifier == identifier })
        let result = try modelContext.fetch(descriptor)
        return !result.isEmpty
    }

    func getPairedDevice(identifier: UUID) async throws -> Bool {
        let descriptor = FetchDescriptor<Device>(predicate: #Predicate { $0.identifier == identifier })
        let result = try modelContext.fetch(descriptor)
        return result.first != nil
    }
}
