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
public actor DevicePairingManager: ObservableObject {
        
    // MARK: - Logging
    private let logger = Logger(subsystem: "com.helpinghand.app", category: "DevicePairingManager")

    // MARK: - Persistence
    private func loadPairedDevices() {
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
    func pairDevice(_ device: Device)
    {
        logger.info("Attempting to pair device: \(device.name) (ID: \(device.identifier))")

        guard !isPaired(device) else {
            logger.warning("Device \(device.name) is already paired, skipping pairing")
            return
        }

        modelContext.insert(device)

        do {
            try modelContext.save()
            loadPairedDevices()
            logger.info("Successfully paired device: \(device.name) (Internal ID: \(device.identifier.uuidString))")
        } catch {
            logger.error("Failed to save paired device: \(error.localizedDescription)")
        }
    }

    func unpairDevice(_ deviceId: UUID) {
        logger.info("Attempting to unpair device with internal ID: \(deviceId.uuidString)")

        if let device = pairedDevices.first(where: { $0.id == deviceId }) {
            modelContext.delete(device)
            do {
                try modelContext.save()
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


//import Foundation
//import SwiftData
//import CoreData
//
///// ```swift
/////  // It is important that this actor works as a mutex,
/////  // so you must have one instance of the Actor for one container
////   // for it to work correctly.
/////  let actor = BackgroundSerialPersistenceActor(container: modelContainer)
/////
/////  Task {
/////      let data: [MyModel] = try? await actor.fetchData()
/////  }
/////  ```
//@ModelActor
//public final actor BackgroundSerialPersistenceActor {
//    
//    func fetchData<T: PersistentModel>(
//        predicate: Predicate<T>? = nil,
//        sortBy: [SortDescriptor<T>] = []
//    ) throws -> [T] {
//        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
//        let list: [T] = try modelContext.fetch(fetchDescriptor)
//        return list
//    }
//
//    func fetchCount<T: PersistentModel>(
//        predicate: Predicate<T>? = nil,
//        sortBy: [SortDescriptor<T>] = []
//    ) throws -> Int {
//        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
//        let count = try modelContext.fetchCount(fetchDescriptor)
//        return count
//    }
//
//    public func insert<T: PersistentModel>(data: T) {
//        let context = data.modelContext ?? modelContext
//        context.insert(data)
//    }
//
//    public func save() throws {
//        try modelContext.save()
//    }
//
//    public func remove<T: PersistentModel>(predicate: Predicate<T>? = nil) throws {
//        try modelContext.delete(model: T.self, where: predicate)
//    }
//
//    public func saveAndInsertIfNeeded<T: PersistentModel>(
//        data: T,
//        predicate: Predicate<T>
//    ) throws {
//        let descriptor = FetchDescriptor<T>(predicate: predicate)
//        let context = data.modelContext ?? modelContext
//        let savedCount = try context.fetchCount(descriptor)
//
//        if savedCount == 0 {
//            context.insert(data)
//        }
//        try context.save()
//    }
//}
