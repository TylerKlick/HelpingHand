//
//  DeviceConnectionState.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

/// Stages of device connection through the BluetoothManager FSM
public enum DeviceConnectionState: String {
    case disconnected = "disconnected"
    case connecting = "connecting"
    case connected = "connected"
    case disconnecting = "disconnecting"
    case validating = "validating"
    case validated = "validated"
    case validationFailed = "validationFailed"
}
