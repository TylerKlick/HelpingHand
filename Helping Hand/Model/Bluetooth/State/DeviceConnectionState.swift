//
//  DeviceConnectionState.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

/// Stages of device connection through the BluetoothManager FSM
public enum DeviceConnectionState {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case validating
    case validated
    case validationFailed
}
