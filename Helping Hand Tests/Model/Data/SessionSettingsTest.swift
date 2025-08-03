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

@Suite("SessionSetings")
@MainActor
struct SessionSettingsTest {
    
    @Suite("Persistence")
    @MainActor
    struct SessionSettingsPersistenceTests {
        
        // MARK: - Setup
        private let container: ModelContainer!
        private let context: ModelContext!

        init() {
            // Fresh in-memory store for every test instance
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                container = try ModelContainer(for: SessionSettings.self, configurations: config)
                context = container.mainContext
            } catch {
                fatalError("Failed to create in-memory container: \(error)")
            }
        }
        
        private static func valuesMatch(_ lhs: SessionSettings, _ rhs: SessionSettings) -> Bool {
            lhs.channelMap         == rhs.channelMap         &&
            lhs.sEMGSampleRate     == rhs.sEMGSampleRate     &&
            lhs.imuSampleRate      == rhs.imuSampleRate      &&
            lhs.overlapRatio       == rhs.overlapRatio       &&
            lhs.windowSize         == rhs.windowSize         &&
            lhs.windowType         == rhs.windowType
        }
        
        // MARK: - Tests
        @Test("Insert and fetch SessionSettings")
        func insertAndFetch() throws {
            let settings = SessionSettings(
                channelMap: [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate: 500,
                overlapRatio: 0.5,
                windowSize: 64,
                windowType: .hamming
            )
            context.insert(settings)
            
            // 2. Save (force-flush to the in-memory store)
            try context.save()
            
            // 3. Fetch back
            let descriptor = FetchDescriptor<SessionSettings>()
            let results = try context.fetch(descriptor)
            
            #expect(results.count == 1)
            #expect(results.first?.fingerprint == settings.fingerprint)
        }
        
        @Test("Store keeps original object on duplicate insert")
        func storeKeepsOriginalObject() throws {
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
            
            // Fetch the single row with that fingerprint
            #expect(settings1.fingerprint == settings2.fingerprint)
            let fingerprint = settings1.fingerprint
            let fetch = FetchDescriptor<SessionSettings>(
                predicate: #Predicate { $0.fingerprint == fingerprint }
            )
            let results = try context.fetch(fetch)
            
            // We expect the upsert to have replaced this data due to the matching unique values
            #expect(settings1.id != settings2.id)
            #expect(results.count == 1)
            #expect(results.first!.id == settings1.id)
            #expect(results.first!.id != settings2.id)
            
            // We don't expect any mutation to any data
            #expect(SessionSettingsPersistenceTests.valuesMatch(settings1, settings2))
            #expect(SessionSettingsPersistenceTests.valuesMatch(settings1, results.first!))
            #expect(SessionSettingsPersistenceTests.valuesMatch(settings2, results.first!))
        }
        
        @Test("Distinct SessionSettings are stored separately")
        func distinctObjectsAreStored() throws {

            let settings1 = SessionSettings(
                channelMap: [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate:  500,
                overlapRatio:   0.5,
                windowSize:     64,
                windowType:     .hamming
            )

            let settings2 = SessionSettings(
                channelMap: [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate:  500,
                overlapRatio:   0.75,
                windowSize:     64,
                windowType:     .hamming
            )

            context.insert(settings1)
            context.insert(settings2)
            try context.save()

            let all = try context.fetch(FetchDescriptor<SessionSettings>())
            #expect(all.count == 2, "Two distinct settings must be persisted")
            #expect(all.contains(settings1))
            #expect(all.contains(settings2))
        }
        
        @Test("Multiple Sessions pointing to the same SessionSettings")
        func sharedSettings() throws {
            
            // Create SessionSettings
            let settings =  SessionSettings(
                channelMap: [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate: 500,
                overlapRatio: 0.5,
                windowSize: 64,
                windowType: .hamming
            )
            context.insert(settings)
            
            // Create sessions
            let session1 = Session(settings)
            context.insert(session1)

            let session2 = Session(settings)
            context.insert(session2)

            // Save to database
            try context.save()

            // Validate relationship link
            let fetchedSettings = try context.fetch(FetchDescriptor<SessionSettings>())
            #expect(fetchedSettings.count == 1, "Only one settings row")
            #expect(fetchedSettings.first?.sessions.count == 2)
            #expect(((fetchedSettings.first?.sessions.contains(session1)) != nil))
            #expect(((fetchedSettings.first?.sessions.contains(session2)) != nil))

            let sessions = try context.fetch(FetchDescriptor<Session>())
            #expect(sessions.count == 2)
            sessions.forEach { session in
               #expect(session.settings?.id == settings.id)
            }
        }
        
        @Test("Deleting SessionSettings nullifies every Session.settings")
        func nullifyOnDelete() throws {
            
            // Create SessionSettings
            let settings =  SessionSettings(
                channelMap: [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate: 500,
                overlapRatio: 0.5,
                windowSize: 64,
                windowType: .hamming
            )
            context.insert(settings)
            
            // Create sessions
            let session1 = Session(settings)
            context.insert(session1)

            let session2 = Session(settings)
            context.insert(session2)

            // Save to database
            try context.save()

            // Validate relationship link
            let fetchedSettings = try context.fetch(FetchDescriptor<SessionSettings>())
            #expect(fetchedSettings.count == 1, "Only one settings row")

            let sessions = try context.fetch(FetchDescriptor<Session>())
            #expect(sessions.count == 2)
            sessions.forEach { session in
               #expect(session.settings?.id == settings.id)
            }
            
            // Remove SessionSettings
            context.delete(settings)
            try context.save()
            
            // Validate all sessions were removed
            let sessionsAfterDelete = try context.fetch(FetchDescriptor<Session>())
            #expect(sessionsAfterDelete.isEmpty)
        }
        
        @Test("SessionSettings sessions adds correct Session relationship")
        func sessionRelationship() throws {
            
            // Create SessionSettings
            let settings =  SessionSettings(
                channelMap: [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate: 500,
                overlapRatio: 0.5,
                windowSize: 64,
                windowType: .hamming
            )
            context.insert(settings)
            
            // Create sessions
            let session = Session(settings)
            context.insert(session)
            
            // Validate addition
            let fresh = try context.fetch(FetchDescriptor<SessionSettings>()).first!
            #expect(fresh.sessions.count == 1)
            #expect(fresh.sessions.first?.id == session.id)
            #expect(fresh.sessions.first == session)
            
            
        }
    }
    
    @Suite("Fingerprint")
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
            #expect(base.fingerprint != other.fingerprint)
        }
        
        @Test("Channel-map key order is normalized")
        func channelMapOrderIsNormalized() {
            let base   = makeBase()
            let reordered = SessionSettings(
                channelMap:     [.bicep: 1, .forearm: 0], // reversed key order
                sEMGSampleRate: 1_000,
                imuSampleRate:  500,
                overlapRatio:   0.5,
                windowSize:     64,
                windowType:     .hamming
            )
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
            #expect(base.fingerprint != other.fingerprint)
        }
    }
}
