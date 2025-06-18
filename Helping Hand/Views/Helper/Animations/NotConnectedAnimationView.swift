//
//  NotConnectedView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/16/25.
//

import SwiftUI

struct NotConnectedAnimationView: View {
    @State private var wiggle = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack {                  
                Text("🖐️")
                    .font(.system(size: 80))
                    .opacity(0.5)
                
                Text("🚫")
                    .font(.system(size: 60))
                    .rotationEffect(.degrees(wiggle ? -10 : 10))
                    .opacity(wiggle ? 1.0 : 0.6)
                    .scaleEffect(wiggle ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: wiggle
                    )
            }

            Text("Device Not Connected")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .onAppear {
            wiggle = true
        }
    }
}

#Preview {
    NotConnectedAnimationView()
        .padding()
}
