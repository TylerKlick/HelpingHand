//
//  DevicePairingManager.swift
//  Helping Hand
//
//  Created by Tyler Klick on 8/6/25.
//

import AccessorySetupKit

class DevicePairingManagerSwift {
    
    private(set) var session = ASAccessorySession()
    
    private(set) var discoveredAccessories: [ASAccessory] = []
    
    init() {
        session.activate(on: DispatchQueue.main, eventHandler: handleSessionEvent(event:))
    }
    
    func handleSessionEvent(event: ASAccessoryEvent) {
        switch event.eventType {
        case .activated:
            print("Session is activated and ready to use")
            print(session.accessories)
            discoveredAccessories = session.accessories
        default:
            print("Received event type \(event.eventType)")
        }
    }
    
}
