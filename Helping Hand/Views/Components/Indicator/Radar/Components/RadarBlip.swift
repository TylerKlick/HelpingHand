//
//  Blip.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/21/25.
//

import SwiftUI

struct RadarBlip: Identifiable, Hashable {
    var id = UUID() 
    let radialOffset: CGFloat
    let angularOffset: Double
    let delay: Double
    let scannerSpeed: Double
    
    init(currentRotation: CGFloat, blipSize: CGFloat, scannerSize: CGFloat, scannerSpeed: Double) {
        radialOffset = CGFloat(Int.random(in: Int(blipSize)...Int((scannerSize / 2) - blipSize)))
        angularOffset = Double(Int.random(in: 0...360))
        self.scannerSpeed = scannerSpeed
        
        // Compute distance and delay given constant speed (90 added to account for gradient offset)
        let distance = RadarBlip.clockwiseDistance( scannerPos: currentRotation, blipPos: angularOffset) + 90
        delay = (scannerSpeed / 360.0 ) * distance
    }
    
    /// Computes the clockwise angular distance between two angles on a circle.
    ///
    /// This method safely normalizes both input angles to the range [0, 360) degrees,
    /// then calculates the clockwise distance from the scanner's position to the blip's position.
    ///
    /// - Parameters:
    ///   - scannerPos: The angle of the scanner position in degrees. Can be any real number.
    ///   - blipPos: The angle of the blip position in degrees. Can be any real number.
    /// - Returns: The clockwise distance from `scannerPos` to `blipPos`, in degrees, in the range [0, 360).
    static func clockwiseDistance(
                           scannerPos: Double,
                           blipPos: Double) -> Double {
        
        // Ensure that all angles are normalized to the range [0, 360)
        let normalizedScanner = ((scannerPos.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
        let normalizedBlip = ((blipPos.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
        
        // Compute difference and ensure positive
        let delta = normalizedBlip - normalizedScanner
        return delta >= 0 ? delta : delta + 360
    }
}
