//
//  DataManager.swift
//

import Foundation
import SwiftData

@Observable
@MainActor
class DataManager {
    
    private(set) var modelContext: ModelContext? = nil
    private(set) var modelContainer: ModelContainer? = nil
    private(set) var sessions: [Session] = []
    private(set) var error: Error? = nil
    
    init(inMemory: Bool) {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
            let container = try ModelContainer(for: DataFrame.self, Session.self, SessionSettings.self, configurations: configuration)
            
            modelContainer = container
            modelContext = container.mainContext
            modelContext?.autosaveEnabled = true
        
        } catch(let error) {
            print(error)
            print(error.localizedDescription)
            self.error = error
        }
    }
    
    
    func addSession() {
        guard let modelContext = modelContext else {
            print("Model Context is Nil! Please check initialization")
            return
        }
        
    }
    
    func deleteSession() {

    }
    
    func addFrame(to session: Session, label: String, mode: Mode, imu: Data, semg: Data) {
        
    }
    
    func deleteFrame(_ frame: DataFrame) {
        
    }
    
    
    private func querySessions() {
        guard let modelContext = modelContext else {
            print("Model Context is Nil! Please check initialization")
            return
        }
        
        var sessionDescriptor = FetchDescriptor<Session>(
            predicate: nil,
            sortBy: [
                .init(\.startTime)
            ]
        )
        sessionDescriptor.fetchLimit = 10
        do {
            sessions = try modelContext.fetch(sessionDescriptor)
        } catch(let error) {
            self.error = error
        }
    }
}
