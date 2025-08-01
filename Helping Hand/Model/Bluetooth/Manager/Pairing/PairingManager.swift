//
//  DevicePairingManager.swift
//  Helping Hand
//
//  Device pairing and persistence manager
//

import Foundation
import os
import SwiftData

@ModelActor
actor DevicePairingManager {
    
    // MARK: - Logging
    private let logger = Logger(subsystem: "com.helpinghand.app", category: "DevicePairingManager")

    /// URL to store paired devices database
    static let storeURL = URL.documentsDirectory.appending(path: "paired-devices.sqlite")
    
    static let modelConfiguration = ModelConfiguration(
        schema: Schema([Device.self]),
        url: storeURL
    )

    private(set) var pairedDevices: [Device] = []
    
    // MARK: - Persistence
    func loadPairedDevices() async {
        logger.debug("Loading paired devices from SwiftData")

        let descriptor = FetchDescriptor<Device>(sortBy: [SortDescriptor(\.lastSeen, order: .reverse)])
        do {
            pairedDevices = try modelContext.fetch(descriptor)
            logger.info("Successfully loaded \(self.pairedDevices.count) paired devices from SwiftData")
        } catch {
            logger.error("Failed to fetch paired devices: \(error.localizedDescription)")
        }
    }

    // MARK: - Pairing Management
    func pairDevice(_ device: Device) async {
        logger.info("Attempting to pair device: \(device.name) (ID: \(device.identifier))")

        guard !(await isPaired(device)) else {
            logger.warning("Device \(device.name) is already paired, skipping pairing")
            return
        }

        modelContext.insert(device)

        do {
            try modelContext.save()
            await loadPairedDevices()
            logger.info("Successfully paired device: \(device.name) (Internal ID: \(device.identifier.uuidString))")
        } catch {
            logger.error("Failed to save paired device: \(error.localizedDescription)")
        }
    }

    func unpairDevice(_ deviceId: UUID) async {
        logger.info("Attempting to unpair device with internal ID: \(deviceId.uuidString)")

        if let device = pairedDevices.first(where: { $0.id == deviceId }) {
            modelContext.delete(device)
            do {
                try modelContext.save()
                await loadPairedDevices()
                logger.info("Successfully unpaired device: \(device.name)")
            } catch {
                logger.error("Failed to unpair device: \(error.localizedDescription)")
            }
        } else {
            logger.warning("Could not find device with internal ID \(deviceId.uuidString) to unpair")
        }
    }

    func isPaired(_ device: Device) async -> Bool {
        let paired = pairedDevices.contains { $0.identifier == device.identifier }
        logger.debug("Checking if device \(device.name) (ID: \(device.identifier)) is paired: \(paired)")
        return paired
    }

    func getPairedDevice(with identifier: UUID) async -> Device? {
        let pairedDevice = pairedDevices.first { $0.identifier == identifier }

        if let device = pairedDevice {
            logger.debug("Found paired device for \(device.name): \(device.name)")
        } else {
            logger.debug("No paired device found for (ID: \(identifier))")
        }

        return pairedDevice
    }
}
