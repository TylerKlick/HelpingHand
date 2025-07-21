//
//  Blip.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/21/25.
//

import SwiftUI

struct RadarBlip: Identifiable, Hashable {
    var id = UUID() 
    var radialOffset: CGFloat
    var angularOffset: Double
}
