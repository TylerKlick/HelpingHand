import SwiftUI
internal import ConfettiSwiftUI

struct BluetoothSettingsGuideView: View {
    @State private var currentStep = 0
    @State private var bluetoothEnabled = false
    @State private var pulseAnimation = false
    @State private var confettiCount: Int = 0
    
    // Animation timing
    private let stepDuration: Double = 2.5
    private let totalSteps = 3

    var body: some View {
        VStack(spacing: 30) {
            Text("How to Turn On Bluetooth")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            ZStack {
                
                // Step 1: Settings Menu
                if currentStep >= 0 && currentStep < 2 {
                    SettingsMenuView(
                        highlightBluetooth: currentStep >= 1,
                        pulse: pulseAnimation && currentStep == 1
                    )
                    .opacity(currentStep < 2 ? 1.0 : 0.0)
                    .scaleEffect(currentStep < 2 ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.5), value: currentStep)
                }
                
                // Step 2: Bluetooth Toggle
                if currentStep >= 2 {
                    BluetoothToggleView(
                        isEnabled: bluetoothEnabled,
                        pulse: pulseAnimation && currentStep == 2 && !bluetoothEnabled
                    )
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                }
                
                // Confetti overlay
                ConfettiCannon(trigger: $confettiCount)
            }
            .frame(height: 300)
            
            // Status text
            VStack(spacing: 8) {
                switch currentStep {
                case 0:
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundColor(.blue)
                case 1:
                    Text("Find and tap Bluetooth")
                        .font(.headline)
                        .foregroundColor(.blue)
                case 2:
                    Text(bluetoothEnabled ? "Bluetooth is ON!" : "Turn Bluetooth ON")
                        .font(.headline)
                        .foregroundColor(bluetoothEnabled ? .green : .blue)
                default:
                    Text("Complete!")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentStep)
            .animation(.easeInOut(duration: 0.3), value: bluetoothEnabled)
        }
        .padding()
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        pulseAnimation = true
        
        // Step 1: Show settings menu
        currentStep = 0
        bluetoothEnabled = false
        
        // Step 2: Highlight Bluetooth after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
            withAnimation {
                currentStep = 1
            }
        }
        
        // Step 3: Show Bluetooth toggle
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * 2) {
            withAnimation {
                currentStep = 2
            }
        }
        
        // Step 4: Enable Bluetooth and show confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * 2.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                bluetoothEnabled = true
            }
            confettiCount += 1
        }
        
        // Step 5: Restart animation
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * 4) {
            startAnimation()
        }
    }
}

struct TutorialStep: View {
    let stepNumber: Int
    let icon: String
    let title: String
    let description: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
                
                Text("\(stepNumber)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(
                    color: colorScheme == .dark ? .clear : .black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }
}

#Preview {
    BluetoothSettingsGuideView()
}
