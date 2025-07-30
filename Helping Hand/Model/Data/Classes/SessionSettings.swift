//
//  SessionSettings.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/24/25.
//
//

import Foundation
import SwiftData
import CryptoKit

@Model public class SessionSettings: Equatable {
    
    /// Unique SHA-256 identifier to prevent duplicate SessionSettings creation
    @Attribute(.unique)
    private(set) var fingerprint: String = ""
    
    /// One to many relationship with Sessions -- many sessions can share the same settings, but each may only have one SessionSettings
    @Relationship(inverse: \Session.settings)
    private(set) var sessions: [Session] = []
    
    // MARK: - Sampling Settings
    private(set) var channelMap: [SensorLocation : Int] = [SensorLocation.forearm : 0]
    private(set) var sEMGSampleRate: Double
    private(set) var imuSampleRate: Double
    
    // MARK: - Pre-processing Settings
    private(set) var overlapRatio: Float
    private(set) var windowSize: Int32
    private(set) var windowType: WindowType = WindowType.hamming

    public init(channelMap: [SensorLocation : Int], sEMGSampleRate: Double = 1_000, imuSampleRate: Double = 1_000, overlapRatio: Float = 0.5, windowSize: Int32 = 32, windowType: WindowType = .hamming) {
        self.channelMap = channelMap
        self.sEMGSampleRate = sEMGSampleRate
        self.imuSampleRate = imuSampleRate
        self.overlapRatio = overlapRatio
        self.windowSize = windowSize
        self.windowType = windowType
        self.fingerprint = deterministicHash()
    }
    
    /// Equatable function. Uses the SHA-256 fingerprint values to determine if two settings values are equivalent
    ///
    /// - Parameters:
    ///   - lhs: the first SessionSettings instance to compare
    ///   - rhs: the second SessionSettings instance to compare
    /// - Returns: true if lhs and rhs fingerprints are identical, false otherwise.
    public static func == (lhs: SessionSettings, rhs: SessionSettings) -> Bool {
        return lhs.fingerprint == rhs.fingerprint
    }
    
    /// Compuites a deterministic Hash value for efficient Duplicate settings lookups
    ///
    /// - Returns: the deterministic hash of the SessionSettings instance.
    private func deterministicHash() -> String {
           let components: [String] = [
                channelMap.sorted(by: { $0.key.rawValue < $1.key.rawValue })
                    .map { "\($0):\($1)" }
                    .joined(separator: ","),
                String(sEMGSampleRate),
                String(imuSampleRate),
                String(overlapRatio),
                String(windowSize),
                windowType.rawValue
           ]

           let combined = components.joined(separator: "|")
           let hash = SHA256.hash(data: Data(combined.utf8))
           return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
}
