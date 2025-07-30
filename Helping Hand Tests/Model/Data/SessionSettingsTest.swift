////
////  SessionSettingsFingerprintTests.swift
////  Helping Hand Tests
////
////  Created by Tyler Klick on 7/30/25.
////
//
//import Foundation
//import SwiftData
//import Testing
//@testable import Helping_Hand
//
//@MainActor
//struct SessionSettingsPersistenceTests {
//
//    // MARK: - Boiler-plate
//    private static func valuesMatch(_ lhs: SessionSettings, _ rhs: SessionSettings) -> Bool {
//        lhs.channelMap         == rhs.channelMap         &&
//        lhs.sEMGSampleRate     == rhs.sEMGSampleRate     &&
//        lhs.imuSampleRate      == rhs.imuSampleRate      &&
//        lhs.overlapRatio       == rhs.overlapRatio       &&
//        lhs.windowSize         == rhs.windowSize         &&
//        lhs.windowType         == rhs.windowType
//    }
//
//    /// In-memory container that lives only for the lifetime of the test.
//    private static let container: ModelContainer = {
//        do {
//            let config = ModelConfiguration(isStoredInMemoryOnly: true)
//            return try ModelContainer(for: SessionSettings.self, configurations: config)
//        } catch {
//            fatalError("Failed to create in-memory container: \(error)")
//        }
//    }()
//
//    /// Fresh context for every test so tests can’t interfere with each other.
//    private var context: ModelContext { Self.container.mainContext }
//
//    // MARK: - Tests
//    @Test("Insert and fetch SessionSettings")
//    func insertAndFetch() throws {
//        let settings = SessionSettings(
//            channelMap: [.forearm: 0],
//            sEMGSampleRate: 1_000,
//            imuSampleRate: 500,
//            overlapRatio: 0.5,
//            windowSize: 64,
//            windowType: .hamming
//        )
//        context.insert(settings)
//
//        // 2. Save (force-flush to the in-memory store)
//        try context.save()
//
//        // 3. Fetch back
//        let descriptor = FetchDescriptor<SessionSettings>()
//        let results = try context.fetch(descriptor)
//
//        #expect(results.count == 1)
//        #expect(results.first?.fingerprint == settings.fingerprint)
//    }
//
//    @Test("Store keeps original object on duplicate insert")
//    func storeKeepsOriginalObject() throws {
//        let settings1 = SessionSettings(
//            channelMap: [.forearm: 0],
//            sEMGSampleRate: 1_000,
//            imuSampleRate: 500,
//            overlapRatio: 0.5,
//            windowSize: 64,
//            windowType: .hamming
//        )
//        context.insert(settings1)
//        try context.save()
//
//        let settings2 = SessionSettings(
//            channelMap: [.forearm: 0],
//            sEMGSampleRate: 1_000,
//            imuSampleRate: 500,
//            overlapRatio: 0.5,
//            windowSize: 64,
//            windowType: .hamming
//        )
//        context.insert(settings2)
//        try context.save()
//
//        // Fetch the single row with that fingerprint
//        #expect(settings1.fingerprint == settings2.fingerprint)
//        let fingerprint = settings1.fingerprint
//        let fetch = FetchDescriptor<SessionSettings>(
//            predicate: #Predicate { $0.fingerprint == fingerprint }
//        )
//        let results = try context.fetch(fetch)
//        
//        // We expect the upsert to have replaced this data due to the matching unique values
//        #expect(settings1.id != settings2.id)
//        #expect(results.count == 1)
//        #expect(results.first!.id == settings1.id)
//        #expect(results.first!.id != settings2.id)
//        
//        // We don't expect any mutation to any data
//        #expect(SessionSettingsPersistenceTests.valuesMatch(settings1, settings2))
//        #expect(SessionSettingsPersistenceTests.valuesMatch(settings1, results.first!))
//        #expect(SessionSettingsPersistenceTests.valuesMatch(settings2, results.first!))
//    }
//}
//
//struct SessionSettingsFingerprintTests {
//
//    // MARK: - Baseline
//
//    private func makeBase() -> SessionSettings {
//        SessionSettings(
//            channelMap:     [.forearm: 0, .bicep: 1],
//            sEMGSampleRate: 1_000,
//            imuSampleRate:  500,
//            overlapRatio:   0.5,
//            windowSize:     64,
//            windowType:     .hamming
//        )
//    }
//
//    // MARK: - Channel-Map Variations
//
//    @Test("Fingerprint changes when channelMap adds key")
//    func channelMapAddsKey() {
//        let base  = makeBase()
//        let other = SessionSettings(
//            channelMap:     [.forearm: 0, .bicep: 1, .wrist: 3], // added .wrist
//            sEMGSampleRate: 1_000,
//            imuSampleRate:  500,
//            overlapRatio:   0.5,
//            windowSize:     64,
//            windowType:     .hamming
//        )
//        #expect(base.fingerprint != other.fingerprint)
//    }
//
//    @Test("Fingerprint changes when channelMap removes key")
//    func channelMapRemovesKey() {
//        let base  = makeBase()
//        let other = SessionSettings(
//            channelMap:     [.forearm: 0], // removed .bicep
//            sEMGSampleRate: 1_000,
//            imuSampleRate:  500,
//            overlapRatio:   0.5,
//            windowSize:     64,
//            windowType:     .hamming
//        )
//        #expect(base.fingerprint != other.fingerprint)
//    }
//
//    @Test("Fingerprint changes when channelMap value changes")
//    func channelMapValueChanges() {
//        let base  = makeBase()
//        let other = SessionSettings(
//            channelMap:     [.forearm: 42, .bicep: 1], // forearm value changed
//            sEMGSampleRate: 1_000,
//            imuSampleRate:  500,
//            overlapRatio:   0.5,
//            windowSize:     64,
//            windowType:     .hamming
//        )
//        #expect(base.fingerprint != other.fingerprint)
//    }
//
//    @Test("Channel-map key order is normalized")
//    func channelMapOrderIsNormalized() {
//        let base   = makeBase()
//        let reordered = SessionSettings(
//            channelMap:     [.bicep: 1, .forearm: 0], // reversed key order
//            sEMGSampleRate: 1_000,
//            imuSampleRate:  500,
//            overlapRatio:   0.5,
//            windowSize:     64,
//            windowType:     .hamming
//        )
//        #expect(base.fingerprint == reordered.fingerprint)
//    }
//
//    // MARK: - Sampling-Rate Variations
//
//    @Test("Fingerprint changes when sEMGSampleRate changes")
//    func semgSampleRateChanges() {
//        let base  = makeBase()
//        let other = SessionSettings(
//            channelMap:     base.channelMap,
//            sEMGSampleRate: 2_048, // changed
//            imuSampleRate:  base.imuSampleRate,
//            overlapRatio:   base.overlapRatio,
//            windowSize:     base.windowSize,
//            windowType:     base.windowType
//        )
//        #expect(base.fingerprint != other.fingerprint)
//    }
//
//    @Test("Fingerprint changes when imuSampleRate changes")
//    func imuSampleRateChanges() {
//        let base  = makeBase()
//        let other = SessionSettings(
//            channelMap:     base.channelMap,
//            sEMGSampleRate: base.sEMGSampleRate,
//            imuSampleRate:  200,   // changed
//            overlapRatio:   base.overlapRatio,
//            windowSize:     base.windowSize,
//            windowType:     base.windowType
//        )
//        #expect(base.fingerprint != other.fingerprint)
//    }
//
//    // MARK: - Pre-processing Variations
//
//    @Test("Fingerprint changes when overlapRatio changes")
//    func overlapRatioChanges() {
//        let base  = makeBase()
//        let other = SessionSettings(
//            channelMap:     base.channelMap,
//            sEMGSampleRate: base.sEMGSampleRate,
//            imuSampleRate:  base.imuSampleRate,
//            overlapRatio:   0.75, // changed
//            windowSize:     base.windowSize,
//            windowType:     base.windowType
//        )
//        #expect(base.fingerprint != other.fingerprint)
//    }
//
//    @Test("Fingerprint changes when windowSize changes")
//    func windowSizeChanges() {
//        let base  = makeBase()
//        let other = SessionSettings(
//            channelMap:     base.channelMap,
//            sEMGSampleRate: base.sEMGSampleRate,
//            imuSampleRate:  base.imuSampleRate,
//            overlapRatio:   base.overlapRatio,
//            windowSize:     128,  // changed
//            windowType:     base.windowType
//        )
//        #expect(base.fingerprint != other.fingerprint)
//    }
//
//    @Test("Fingerprint changes when windowType changes")
//    func windowTypeChanges() {
//        let base  = makeBase()
//        let other = SessionSettings(
//            channelMap:     base.channelMap,
//            sEMGSampleRate: base.sEMGSampleRate,
//            imuSampleRate:  base.imuSampleRate,
//            overlapRatio:   base.overlapRatio,
//            windowSize:     base.windowSize,
//            windowType:     .hanning // changed
//        )
//        #expect(base.fingerprint != other.fingerprint)
//    }
//}
//

//
//  SessionSettingsFingerprintTests.swift
//  Helping Hand Tests
//
//  Created by Tyler Klick on 7/30/25.
//

import Foundation
import SwiftData
import Testing
@testable import Helping_Hand

@Suite("SessionSettings")
@MainActor
struct SessionSettingsTests {
    
    enum ContainerKind: CaseIterable {
        case inMemory
        case onDisk
    }

    private static func valuesMatch(_ lhs: SessionSettings, _ rhs: SessionSettings) -> Bool {
        lhs.channelMap         == rhs.channelMap         &&
        lhs.sEMGSampleRate     == rhs.sEMGSampleRate     &&
        lhs.imuSampleRate      == rhs.imuSampleRate      &&
        lhs.overlapRatio       == rhs.overlapRatio       &&
        lhs.windowSize         == rhs.windowSize         &&
        lhs.windowType         == rhs.windowType
    }

    @MainActor
    @Suite("Persistence")
    struct SessionSettingsPersistenceTests {

        private var container: ModelContainer
        private var context: ModelContext

        /// Initialised by the runner for every test instance.
        init(for kind: ContainerKind) {
            self.container = Self.makeContainer(kind: kind)
            self.context   = container.mainContext
        }

        // MARK: - Helpers --------------------------------------------------------

        private static func makeContainer(kind: ContainerKind) -> ModelContainer {
            let schema = Schema([SessionSettings.self, Session.self])

            let config: ModelConfiguration
            switch kind {
            case .inMemory:
                config = ModelConfiguration(isStoredInMemoryOnly: true)
            case .onDisk:
                let url = FileManager.default
                    .temporaryDirectory
                    .appendingPathComponent("SessionSettingsTests-\(UUID().uuidString)")
                config = ModelConfiguration(url: url)
            }

            return try! ModelContainer(for: schema, configurations: [config])
        }

        /// Reset the store for the current kind.
        @discardableResult
        private mutating func resetContainer() -> ModelContext {
            let kind: ContainerKind = (container.configurations.first?.isStoredInMemoryOnly == true)
                                      ? .inMemory : .onDisk
            self.container = Self.makeContainer(kind: kind)
            self.context   = container.mainContext
            return context
        }

        /// Value-based equality, ignoring object identity.
        private static func valuesMatch(_ lhs: SessionSettings,
                                        _ rhs: SessionSettings) -> Bool {
            lhs.channelMap == rhs.channelMap &&
            lhs.sEMGSampleRate == rhs.sEMGSampleRate &&
            lhs.imuSampleRate == rhs.imuSampleRate &&
            lhs.overlapRatio == rhs.overlapRatio &&
            lhs.windowSize == rhs.windowSize &&
            lhs.windowType == rhs.windowType
        }

        // MARK: - Tests -----------------------------------------------------------

        @Test(arguments: [ContainerKind.inMemory, ContainerKind.onDisk])
        mutating func insertAndFetch(for kind: ContainerKind) async throws {
            let context = resetContainer()

            let settings = SessionSettings(
                channelMap: [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate: 500,
                overlapRatio: 0.5,
                windowSize: 64,
                windowType: .hamming
            )
            context.insert(settings)
            try context.save()

            let descriptor = FetchDescriptor<SessionSettings>()
            let results = try context.fetch(descriptor)

            #expect(results.count == 1)
            #expect(results.first?.fingerprint == settings.fingerprint)
        }

        @Test(arguments: [ContainerKind.inMemory, ContainerKind.onDisk])
        mutating func storeKeepsOriginalObject(for kind: ContainerKind) async throws {
            let context = resetContainer()

            let settings1 = SessionSettings(
                channelMap: [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate: 500,
                overlapRatio: 0.5,
                windowSize: 64,
                windowType: .hamming
            )
            context.insert(settings1)
            try context.save()

            let settings2 = SessionSettings(
                channelMap: [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate: 500,
                overlapRatio: 0.5,
                windowSize: 64,
                windowType: .hamming
            )
            context.insert(settings2)
            try context.save()

            #expect(settings1.fingerprint == settings2.fingerprint)
            let fingerprint = settings1.fingerprint
            let fetch = FetchDescriptor<SessionSettings>(
                predicate: #Predicate { $0.fingerprint == fingerprint }
            )
            let results = try context.fetch(fetch)

            #expect(settings1.id != settings2.id)
            #expect(results.count == 1)
            #expect(results.first!.id == settings1.id)
            #expect(results.first!.id != settings2.id)

            #expect(Self.valuesMatch(settings1, settings2))
            #expect(Self.valuesMatch(settings1, results.first!))
            #expect(Self.valuesMatch(settings2, results.first!))
        }
    }
    
    // MARK: - Fingerprint
    @MainActor @Suite("fingerprint")
    struct SessionSettingsFingerprintTests {

        private func makeBase() -> SessionSettings {
            SessionSettings(
                channelMap:     [.forearm: 0, .bicep: 1],
                sEMGSampleRate: 1_000,
                imuSampleRate:  500,
                overlapRatio:   0.5,
                windowSize:     64,
                windowType:     .hamming
            )
        }

        // MARK: - Channel-Map Variations

        @Test("Fingerprint changes when channelMap adds key")
        func channelMapAddsKey() {
            let base  = makeBase()
            let other = SessionSettings(
                channelMap:     [.forearm: 0, .bicep: 1, .wrist: 3], // added .wrist
                sEMGSampleRate: 1_000,
                imuSampleRate:  500,
                overlapRatio:   0.5,
                windowSize:     64,
                windowType:     .hamming
            )
            
            #expect(!valuesMatch(base, other))
            #expect(base.fingerprint != other.fingerprint)
        }

        @Test("Fingerprint changes when channelMap removes key")
        func channelMapRemovesKey() {
            let base  = makeBase()
            let other = SessionSettings(
                channelMap:     [.forearm: 0], // removed .bicep
                sEMGSampleRate: 1_000,
                imuSampleRate:  500,
                overlapRatio:   0.5,
                windowSize:     64,
                windowType:     .hamming
            )
            #expect(!valuesMatch(base, other))
            #expect(base.fingerprint != other.fingerprint)
        }

        @Test("Fingerprint changes when channelMap value changes")
        func channelMapValueChanges() {
            let base  = makeBase()
            let other = SessionSettings(
                channelMap:     [.forearm: 42, .bicep: 1], // forearm value changed
                sEMGSampleRate: 1_000,
                imuSampleRate:  500,
                overlapRatio:   0.5,
                windowSize:     64,
                windowType:     .hamming
            )
            #expect(!valuesMatch(base, other))
            #expect(base.fingerprint != other.fingerprint)
        }

        @Test("Channel-map key order is normalized")
        func channelMapOrderIsNormalized() {
            let base    = makeBase()
            let reordered = SessionSettings(
                channelMap:     [.bicep: 1, .forearm: 0], // reversed key order
                sEMGSampleRate: 1_000,
                imuSampleRate:  500,
                overlapRatio:   0.5,
                windowSize:     64,
                windowType:     .hamming
            )
            #expect(valuesMatch(base, reordered))
            #expect(base.fingerprint == reordered.fingerprint)
        }

        // MARK: - Sampling-Rate Variations

        @Test("Fingerprint changes when sEMGSampleRate changes")
        func semgSampleRateChanges() {
            let base  = makeBase()
            let other = SessionSettings(
                channelMap:     base.channelMap,
                sEMGSampleRate: 2_048, // changed
                imuSampleRate:  base.imuSampleRate,
                overlapRatio:   base.overlapRatio,
                windowSize:     base.windowSize,
                windowType:     base.windowType
            )
            #expect(!valuesMatch(base, other))
            #expect(base.fingerprint != other.fingerprint)
        }

        @Test("Fingerprint changes when imuSampleRate changes")
        func imuSampleRateChanges() {
            let base  = makeBase()
            let other = SessionSettings(
                channelMap:     base.channelMap,
                sEMGSampleRate: base.sEMGSampleRate,
                imuSampleRate:  200,   // changed
                overlapRatio:   base.overlapRatio,
                windowSize:     base.windowSize,
                windowType:     base.windowType
            )
            #expect(!valuesMatch(base, other))
            #expect(base.fingerprint != other.fingerprint)
        }

        // MARK: - Pre-processing Variations

        @Test("Fingerprint changes when overlapRatio changes")
        func overlapRatioChanges() {
            let base  = makeBase()
            let other = SessionSettings(
                channelMap:     base.channelMap,
                sEMGSampleRate: base.sEMGSampleRate,
                imuSampleRate:  base.imuSampleRate,
                overlapRatio:   0.75, // changed
                windowSize:     base.windowSize,
                windowType:     base.windowType
            )
            #expect(!valuesMatch(base, other))
            #expect(base.fingerprint != other.fingerprint)
        }

        @Test("Fingerprint changes when windowSize changes")
        func windowSizeChanges() {
            let base  = makeBase()
            let other = SessionSettings(
                channelMap:     base.channelMap,
                sEMGSampleRate: base.sEMGSampleRate,
                imuSampleRate:  base.imuSampleRate,
                overlapRatio:   base.overlapRatio,
                windowSize:     128,  // changed
                windowType:     base.windowType
            )
            #expect(!valuesMatch(base, other))
            #expect(base.fingerprint != other.fingerprint)
        }

        @Test("Fingerprint changes when windowType changes")
        func windowTypeChanges() {
            let base  = makeBase()
            let other = SessionSettings(
                channelMap:     base.channelMap,
                sEMGSampleRate: base.sEMGSampleRate,
                imuSampleRate:  base.imuSampleRate,
                overlapRatio:   base.overlapRatio,
                windowSize:     base.windowSize,
                windowType:     .hanning // changed
            )
            #expect(!valuesMatch(base, other))
            #expect(base.fingerprint != other.fingerprint)
        }
    }
}
