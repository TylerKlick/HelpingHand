//
//  BlipView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/22/25.
//

import SwiftUI

struct BlipView: View {
    
    @State var opacity: Double = 1.0
    
    let blip: RadarBlip
    let color: Color
    let blipSize: CGFloat
        
    var body: some View {
        Circle()
            .opacity(self.opacity)
            .animation(
                .linear(duration: blip.scannerSpeed)
                .repeatForever(autoreverses: false)
                .delay(blip.delay),
                value: self.opacity
            )
            .frame(width: self.blipSize, height: self.blipSize)
            .foregroundColor(self.color)
            .offset(x: blip.radialOffset, y: 0.0)
            .rotationEffect(Angle(degrees: self.blip.angularOffset))
            .blur(radius: 2.0)
            .onAppear { self.opacity = 0 }
    }
}
