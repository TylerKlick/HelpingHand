//
//  SessionSettingsFingerprintTests.swift
//  Helping Hand Tests
//
//  Created by Tyler Klick on 7/30/25.
//

import XCTest
@testable import Helping_Hand

final class SessionSettingsFingerprintTests: XCTestCase {

    // MARK: - Baseline

    private let base = SessionSettings(
        channelMap:     [.forearm: 0, .bicep: 1],
        sEMGSampleRate: 1_000,
        imuSampleRate:  500,
        overlapRatio:   0.5,
        windowSize:     64,
        windowType:     .hamming
    )

    // MARK: - Channel-Map variations

    func testFingerprintChangesWhenChannelMapAddsKey() {
        let other = SessionSettings(
            channelMap:     [.forearm: 0, .bicep: 1, .wrist: 3], // added .wrist
            sEMGSampleRate: 1_000,
            imuSampleRate:  500,
            overlapRatio:   0.5,
            windowSize:     64,
            windowType:     .hamming
        )
        XCTAssertNotEqual(base.fingerprint, other.fingerprint)
    }

    func testFingerprintChangesWhenChannelMapRemovesKey() {
        let other = SessionSettings(
            channelMap:     [.forearm: 0], // removed .bicep
            sEMGSampleRate: 1_000,
            imuSampleRate:  500,
            overlapRatio:   0.5,
            windowSize:     64,
            windowType:     .hamming
        )
        XCTAssertNotEqual(base.fingerprint, other.fingerprint)
    }

    func testFingerprintChangesWhenChannelMapValueChanges() {
        let other = SessionSettings(
            channelMap:     [.forearm: 42, .bicep: 1], // forearm value changed
            sEMGSampleRate: 1_000,
            imuSampleRate:  500,
            overlapRatio:   0.5,
            windowSize:     64,
            windowType:     .hamming
        )
        XCTAssertNotEqual(base.fingerprint, other.fingerprint)
    }

    func testChannelMapKeyOrderIsNormalized() {
        let ordered = SessionSettings(
            channelMap:     [.bicep: 1, .forearm: 0], // reversed key order
            sEMGSampleRate: 1_000,
            imuSampleRate:  500,
            overlapRatio:   0.5,
            windowSize:     64,
            windowType:     .hamming
        )
        XCTAssertEqual(base.fingerprint, ordered.fingerprint,
                       "Key order in channelMap should not affect fingerprint")
    }

    // MARK: - Sampling-rate variations

    func testFingerprintChangesWhenSEMGSampleRateChanges() {
        let other = SessionSettings(
            channelMap:     base.channelMap,
            sEMGSampleRate: 2_048, // changed
            imuSampleRate:  base.imuSampleRate,
            overlapRatio:   base.overlapRatio,
            windowSize:     base.windowSize,
            windowType:     base.windowType
        )
        XCTAssertNotEqual(base.fingerprint, other.fingerprint)
    }

    func testFingerprintChangesWhenIMUSampleRateChanges() {
        let other = SessionSettings(
            channelMap:     base.channelMap,
            sEMGSampleRate: base.sEMGSampleRate,
            imuSampleRate:  200,   // changed
            overlapRatio:   base.overlapRatio,
            windowSize:     base.windowSize,
            windowType:     base.windowType
        )
        XCTAssertNotEqual(base.fingerprint, other.fingerprint)
    }

    // MARK: - Pre-processing variations

    func testFingerprintChangesWhenOverlapRatioChanges() {
        let other = SessionSettings(
            channelMap:     base.channelMap,
            sEMGSampleRate: base.sEMGSampleRate,
            imuSampleRate:  base.imuSampleRate,
            overlapRatio:   0.75, // changed
            windowSize:     base.windowSize,
            windowType:     base.windowType
        )
        XCTAssertNotEqual(base.fingerprint, other.fingerprint)
    }

    func testFingerprintChangesWhenWindowSizeChanges() {
        let other = SessionSettings(
            channelMap:     base.channelMap,
            sEMGSampleRate: base.sEMGSampleRate,
            imuSampleRate:  base.imuSampleRate,
            overlapRatio:   base.overlapRatio,
            windowSize:     128,  // changed
            windowType:     base.windowType
        )
        XCTAssertNotEqual(base.fingerprint, other.fingerprint)
    }

    func testFingerprintChangesWhenWindowTypeChanges() {
        let other = SessionSettings(
            channelMap:     base.channelMap,
            sEMGSampleRate: base.sEMGSampleRate,
            imuSampleRate:  base.imuSampleRate,
            overlapRatio:   base.overlapRatio,
            windowSize:     base.windowSize,
            windowType:     .hanning // changed
        )
        XCTAssertNotEqual(base.fingerprint, other.fingerprint)
    }
}
