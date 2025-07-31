//
//  DevicePairingManager.swift
//  Helping Hand
//
//  Device pairing and persistence manager
//

import Foundation
import os
import SwiftData

// MARK: - Device Pairing Manager
@MainActor
final class DevicePairingManager: ObservableObject {
    
    private let shared = init(context: nil)
    
    // MARK: - Logging
    private let logger = Logger(subsystem: "com.helpinghand.app", category: "DevicePairingManager")

    @Published private(set) var pairedDevices: [Device] = []

    private let context: ModelContext

    private init() {
        self.context = nil
        logger.info("Initializing DevicePairingManager")
        loadPairedDevices()
    }

    // MARK: - Persistence
    private func loadPairedDevices() {
        logger.debug("Loading paired devices from SwiftData")
        let descriptor = FetchDescriptor<Device>(sortBy: [SortDescriptor(\.lastSeen, order: .reverse)])
        do {
            pairedDevices = try context.fetch(descriptor)
            logger.info("Successfully loaded \(self.pairedDevices.count) paired devices from SwiftData")
        } catch {
            logger.error("Failed to fetch paired devices: \(error.localizedDescription)")
        }
    }

    // MARK: - Pairing Management
    func pairDevice(_ device: Device)
    {
        logger.info("Attempting to pair device: \(device.name) (ID: \(device.identifier))")

        guard !isPaired(device) else {
            logger.warning("Device \(device.name) is already paired, skipping pairing")
            return
        }

        context.insert(device)

        do {
            try context.save()
            loadPairedDevices()
            logger.info("Successfully paired device: \(device.name) (Internal ID: \(device.identifier.uuidString))")
        } catch {
            logger.error("Failed to save paired device: \(error.localizedDescription)")
        }
    }

    func unpairDevice(_ deviceId: UUID) {
        logger.info("Attempting to unpair device with internal ID: \(deviceId.uuidString)")

        if let device = pairedDevices.first(where: { $0.id == deviceId }) {
            context.delete(device)
            do {
                try context.save()
                loadPairedDevices()
                logger.info("Successfully unpaired device: \(device.name)")
            } catch {
                logger.error("Failed to unpair device: \(error.localizedDescription)")
            }
        } else {
            logger.warning("Could not find device with internal ID \(deviceId.uuidString) to unpair")
        }
    }

    func isPaired(_ device: Device) -> Bool {

        let paired = pairedDevices.contains { $0.identifier == device.identifier }
        logger.debug("Checking if device \(device.name) (ID: \(device.identifier)) is paired: \(paired)")
        return paired
    }

    func getPairedDevice(with identifier: UUID) -> Device? {
        let pairedDevice = pairedDevices.first { $0.identifier == identifier }

        if let device = pairedDevice {
            logger.debug("Found paired device for \(device.name): \(device.name)")
        } else {
            logger.debug("No paired device found for (ID: \(identifier))")
        }

        return pairedDevice
    }
}
