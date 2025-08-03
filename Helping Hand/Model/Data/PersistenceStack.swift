//
//  PersistenceStack.swift
//  Helping Hand
//
//  Created by Tyler Klick on 8/1/25.
//
// https://medium.com/@sebasf8/swiftdata-fetch-from-background-thread-c8d9fdcbfbbe

import Foundation
import SwiftData

final class PersistenceStack: Sendable {
    static let shared: PersistenceStack = PersistenceStack()
    let modelContainer: ModelContainer

    private init() {
        do {
            let schema = Schema([
                Device.self,
            ])

            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }
}
