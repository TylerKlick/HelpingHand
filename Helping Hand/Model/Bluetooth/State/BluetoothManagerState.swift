//
//  BluetoothManagerState.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

/// Representation of the Bluetooth Central state
public enum BluetoothManagerState {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}
