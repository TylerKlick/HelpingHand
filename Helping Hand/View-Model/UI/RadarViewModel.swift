//
//  RadarViewModel.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/21/25.
//

import SwiftUI

extension RadarScanner {
    
    @Observable
    class ViewModel {
        
        /// RadarBlips to be displayed
        private(set) var blips = [RadarBlip]()
        
        func addRandomBlip(blipSize: CGFloat, scannerSize: CGFloat) {
            let randomRadialOffet = CGFloat(Int.random(in: Int(blipSize)...Int((scannerSize / 2) - blipSize)))
            let randomAngularOffset = Double(Int.random(in: 0...360))
            
            blips.append(RadarBlip(radialOffset: randomRadialOffet, angularOffset: randomAngularOffset))
        }
        
        func removeBlip() {
            blips.removeLast()
        }
    }
}
