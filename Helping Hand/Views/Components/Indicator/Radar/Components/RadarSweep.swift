//
//  StatusIndicator.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/21/25.
//

import SwiftUI

/// View of Radar scanning arm with Animatable implementation to support live rotation angle binding.
///  Alternativley, a timer couild be used to approximate the angle based on the rotationTime in RadarScanner: (currentTime / totalRotationtime) * 360
struct RadarSweep: View, Animatable {
    
    // MARK: - UI Elements
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let scannerSize: CGFloat
    private var scannerTailColor: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [color.opacity(0), color.opacity(1)]),
            center: .center
        )
    }
    
    // MARK: - Animation parameter elements
    // Tell SwiftUI to update rotation for every degree to alert onChange
    var rotation: CGFloat
    var animatableData: CGFloat {
        get { rotation }
        set { rotation = newValue }
    }
    
    // Pass the current rotation value to the parent view
    @Binding var liveRotation: Double

    // MARK: - View Construction
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.375)
                .stroke(lineWidth: scannerSize / 2)
                .fill(scannerTailColor)
                .frame(width: scannerSize / 2, height: scannerSize / 2)
                .rotationEffect(.degrees(135 + rotation))

            Rectangle()
                .frame(width: 4, height: scannerSize / 2)
                .offset(y: -scannerSize / 4)
                .rotationEffect(.degrees(rotation))
                .foregroundColor(color)
        }
        .frame(width: width, height: height)
        .onChange(of: rotation) { _, newValue in
            liveRotation = Double(newValue) // Assign updated value to Binder var to share status
        }
    }
}

// MARK: - Demo Preview
struct RadarDemo: View {
    @State private var rotation: CGFloat = 0
    @State private var model: Double = 0

    var body: some View {
        VStack(spacing: 40) {
            RadarSweep(
                color: .green,
                width: 300,
                height: 300,
                scannerSize: 250,
                rotation: rotation,
                liveRotation: $model
            )

            Text("Live rotation: \(model, specifier: "%.2f")°")
                .monospacedDigit()
        }
        .animation(
            .linear(duration: 3)
                .repeatForever(autoreverses: false),
            value: rotation
        )
        .onAppear {
            rotation = 360
        }
    }
}

#Preview {
    RadarDemo()
}
