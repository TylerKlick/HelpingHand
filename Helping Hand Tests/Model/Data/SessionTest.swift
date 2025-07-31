//
//  SessionTest.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/31/25.
//

import Foundation
import SwiftData
import Testing
@testable import Helping_Hand

@Suite("Session")
@MainActor
struct SessionTest {
        
    // MARK: - Setup
    private let container: ModelContainer!
    private let context: ModelContext!
    
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            container = try ModelContainer(for: SessionSettings.self, configurations: config)
            context = container.mainContext
            context.autosaveEnabled = true
        } catch {
            fatalError("Failed to create in-memory container: \(error)")
        }
    }
    
    @Test("Adding DataFrames populates the frames array")
    func framesArrayPopulated() throws {
        
        let settings =  SessionSettings(
            channelMap: [.forearm: 0],
            sEMGSampleRate: 1_000,
            imuSampleRate: 500,
            overlapRatio: 0.5,
            windowSize: 64,
            windowType: .hamming
        )
        context.insert(settings)
        
        let session = Session(settings)
        context.insert(session)
        
        for i in 0..<3 {
            let frame = DataFrame(
                session: session,
                label:     "grab",
                mode:      .training,
                imuData:   Data("imu".utf8),
                sEMGData:  Data("semg".utf8),
                timeStamp: Date().addingTimeInterval(Double(i))
            )
            context.insert(frame)
        }
        try context.save()
        
        let fetched = try context.fetch(FetchDescriptor<Session>()).first!
        #expect(fetched.frames?.count == 3)
    }
    
    @Test("Deleting a Session removes its DataFrames")
    func cascadingDelete() throws {
        
        let settings =  SessionSettings(
            channelMap: [.forearm: 0],
            sEMGSampleRate: 1_000,
            imuSampleRate: 500,
            overlapRatio: 0.5,
            windowSize: 64,
            windowType: .hamming
        )
        context.insert(settings)
        
        let session = Session(settings)
        context.insert(session)
        
        let frame = DataFrame(
            session: session,
            label:     "open",
            mode:      .inference,
            imuData:   Data("imu".utf8),
            sEMGData:  Data("semg".utf8),
            timeStamp: Date()
        )
        context.insert(frame)
        try context.save()
        
        context.delete(session)
        try context.save()
        
        let sessions = try context.fetch(FetchDescriptor<Session>())
        let frames   = try context.fetch(FetchDescriptor<DataFrame>())
        #expect(sessions.isEmpty)
        #expect(frames.isEmpty)
    }
    
    @Test("endSession updates endTime")
    func endSession() throws {
        
        let settings =  SessionSettings(
            channelMap: [.forearm: 0],
            sEMGSampleRate: 1_000,
            imuSampleRate: 500,
            overlapRatio: 0.5,
            windowSize: 64,
            windowType: .hamming
        )
        context.insert(settings)
        
        let session = Session(settings)
        #expect(session.endTime == nil)
        context.insert(session)
        try context.save()
        
        let inProgress = try context.fetch(FetchDescriptor<Session>()).first!
        #expect(inProgress.endTime == nil)
        
        session.endSession()
        #expect(session.endTime != nil && session.endTime!.timeIntervalSinceNow < 1)
        try context.save()

        let endedSession = try context.fetch(FetchDescriptor<Session>()).first!
        #expect(endedSession.endTime!.timeIntervalSinceNow < 1)
    }
    
    @Test("addFrame appends to the frames array")
    func addFrameAppends() throws {

        let settings =  SessionSettings(
            channelMap: [.forearm: 0],
            sEMGSampleRate: 1_000,
            imuSampleRate: 500,
            overlapRatio: 0.5,
            windowSize: 64,
            windowType: .hamming
        )
        context.insert(settings)
        
        let session = Session(settings)

        let frame = DataFrame(
            session:   session,
            label:     "fist",
            mode:      .training,
            imuData:   Data("i".utf8),
            sEMGData:  Data("s".utf8),
            timeStamp: Date()
        )
        session.addFrame(frame)
        context.insert(session)
        try context.save()
        
        // Check Object state
        #expect(session.frames?.count == 1)
        #expect(session.frames?.first?.id == frame.id)
        
        // Check persistance in database
        #expect(try context.fetch(FetchDescriptor<Session>()).count == 1)
        let fetchedSession = try context.fetch(FetchDescriptor<Session>()).first!
        #expect(fetchedSession.id == session.id)
        #expect(fetchedSession.frames!.count == 1)
        #expect(fetchedSession.frames!.first!.frameID == frame.frameID)
         
        // Test multiple frames
        for i in 1...5 {

            let frame = DataFrame(
                session:   session,
                label:     "gesture_\(i)",
                mode:      .training,
                imuData:   Data("i\(i)".utf8),
                sEMGData:  Data("s\(i)".utf8),
                timeStamp: Date()
            )
            
            session.addFrame(frame)
        }
        context.insert(session)
        try context.save()
        
        // Check Object state
        #expect(session.frames?.count == 6)
        
        // Check persistance in database
        #expect(try context.fetch(FetchDescriptor<Session>()).count == 1)
        let fetchedSessionMulti = try context.fetch(FetchDescriptor<Session>()).first!
        #expect(fetchedSessionMulti.id == session.id)
        #expect(fetchedSessionMulti.frames!.count == 6)
    }
    
    @Test("addFrame doesn't add duplicates")
    func addFrameAppendDuplicates() throws {

        let settings =  SessionSettings(
            channelMap: [.forearm: 0],
            sEMGSampleRate: 1_000,
            imuSampleRate: 500,
            overlapRatio: 0.5,
            windowSize: 64,
            windowType: .hamming
        )
        context.insert(settings)
        
        let session = Session(settings)

        let frame = DataFrame(
            session:   session,
            label:     "fist",
            mode:      .training,
            imuData:   Data("i".utf8),
            sEMGData:  Data("s".utf8),
            timeStamp: Date()
        )
        session.addFrame(frame)
        context.insert(session)
        try context.save()
        
        // Check Object state
        #expect(session.frames?.count == 1)
        #expect(session.frames?.first?.id == frame.id)
        
        // Check persistance in database
        #expect(try context.fetch(FetchDescriptor<Session>()).count == 1)
        let fetchedSession = try context.fetch(FetchDescriptor<Session>()).first!
        #expect(fetchedSession.id == session.id)
        #expect(fetchedSession.frames!.count == 1)
        #expect(fetchedSession.frames!.first!.frameID == frame.frameID)
        
        // Try to add many duplicates
        for _ in 1...10 {
            session.addFrame(frame)
        }
        context.insert(session)
        try context.save()
        
        // Check Object state
        #expect(session.frames?.count == 1)
        #expect(session.frames?.first?.id == frame.id)
        
        // Check persistance in database
        #expect(try context.fetch(FetchDescriptor<Session>()).count == 1)
        let fetchedSessionAfter = try context.fetch(FetchDescriptor<Session>()).first!
        #expect(fetchedSessionAfter.id == session.id)
        #expect(fetchedSessionAfter.frames!.count == 1)
        #expect(fetchedSessionAfter.frames!.first!.frameID == frame.frameID)
    }
    
    // PLEASE NOTE: you will need to manually delete the frame to ensure that the frame doesn't persist
    @Test("delete single frame from many unique frames")
        func deleteOneFromManyUniqueFrames() throws {

            let settings = SessionSettings(
                channelMap:     [.forearm: 0],
                sEMGSampleRate: 1_000,
                imuSampleRate:  500,
                overlapRatio:   0.5,
                windowSize:     64,
                windowType:     .hamming
            )
            context.insert(settings)

            let session = Session(settings)
            context.insert(session)

            var frames: [DataFrame] = []
            for i in 0..<5 {
                let frame = DataFrame(
                    session:   session,
                    label:     "gesture\(i)",
                    mode:      .training,
                    imuData:   Data("imu\(i)".utf8),
                    sEMGData:  Data("emg\(i)".utf8),
                    timeStamp: Date().addingTimeInterval(Double(i))
                )
                session.addFrame(frame)
                frames.append(frame)
            }
            try context.save()

            #expect(session.frames?.count == 5)
            #expect(try context.fetch(FetchDescriptor<DataFrame>()).count == 5)

            let target = frames[2]
            session.removeFrame(frameID: target.frameID)
            context.insert(session)
            try context.save()

            #expect(session.frames?.count == 4)
            #expect(session.frames?.contains { $0.id == target.id } == false)
        }
}
