//
//  RadarViewModel.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/21/25.
//

import Foundation

extension RadarScanner {
    
    @Observable
    internal class ViewModel {
        
        private(set) var blips = [RadarBlip]()
        var rotation: CGFloat = 0
        var currentRotation: Double = 0
        
        func addRandomBlip(blipSize: CGFloat, scannerSize: CGFloat, scannerSpeed: CGFloat) {
            let newBlip = RadarBlip(
                currentRotation: currentRotation,
                blipSize: blipSize,
                scannerSize: scannerSize,
                scannerSpeed: scannerSpeed
            )
            self.blips.append(newBlip)
        }
        
        func removeBlip() {
            blips.removeLast()
        }
    }
}
