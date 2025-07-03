//import SwiftUI
//
//struct BluetoothSettingsGuideView: View {
//    @State private var currentStep = 0
//    @State private var bluetoothEnabled = false
//    @State private var pulseAnimation = false
//    @State private var isAutoPlaying = false
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 24) {
//                // Title
//                Text("How to Turn On Bluetooth")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//                
//                // Step indicator
//                HStack(spacing: 8) {
//                    ForEach(0..<4) { step in
//                        Circle()
//                            .fill(currentStep > step ? Color.blue : Color.gray.opacity(0.3))
//                            .frame(width: 8, height: 8)
//                            .scaleEffect(currentStep == step ? 1.5 : 1.0)
//                            .animation(.easeInOut(duration: 0.3), value: currentStep)
//                    }
//                }
//                
//                // Animation steps
//                VStack(spacing: 30) {
//                    // Step 1: Open Settings
//                    StepView(
//                        stepNumber: 1,
//                        title: "Open Settings",
//                        isActive: currentStep >= 0
//                    ) {
//                        // Mock iOS home screen with Settings app
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 20)
//                                .fill(Color.black.opacity(0.1))
//                                .frame(width: 200, height: 120)
//                                .overlay(
//                                    Text("iPhone Screen")
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                )
//                            
//                            VStack(spacing: 10) {
//                                // Settings app icon
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .fill(Color.gray)
//                                        .frame(width: 50, height: 50)
//                                    
//                                    Image(systemName: "gear")
//                                        .font(.system(size: 28))
//                                        .foregroundColor(.white)
//                                }
//                                .scaleEffect(currentStep >= 0 && pulseAnimation ? 1.1 : 1.0)
//                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)
//                                
//                                Text("Settings")
//                                    .font(.caption)
//                                    .foregroundColor(.primary)
//                            }
//                            
//                            // Pointing finger
//                            if currentStep >= 0 {
//                                Image(systemName: "hand.point.up.left.fill")
//                                    .font(.system(size: 24))
//                                    .foregroundColor(.orange)
//                                    .offset(x: 40, y: 35)
//                                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
//                                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulseAnimation)
//                            }
//                        }
//                    }
//                    
//                    // Step 2: Find Bluetooth in Settings
//                    StepView(
//                        stepNumber: 2,
//                        title: "Find Bluetooth",
//                        isActive: currentStep >= 1
//                    ) {
//                        // Mock Settings menu
//                        VStack(spacing: 0) {
//                            // Settings header
//                            HStack {
//                                Text("Settings")
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                Spacer()
//                            }
//                            .padding()
//                            .background(Color(.systemGray6))
//                            
//                            // Settings menu items
//                            VStack(spacing: 1) {
//                                SettingsRowView(icon: "airplane", title: "Airplane Mode", color: .orange)
//                                SettingsRowView(icon: "wifi", title: "Wi-Fi", color: .blue)
//                                SettingsRowView(
//                                    icon: "bluetooth",
//                                    title: "Bluetooth",
//                                    color: .blue,
//                                    isHighlighted: currentStep >= 1
//                                )
//                                SettingsRowView(icon: "antenna.radiowaves.left.and.right", title: "Cellular", color: .green)
//                            }
//                            .background(Color(.systemBackground))
//                        }
//                        .frame(width: 250)
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                        )
//                    }
//                    
//                    // Step 3: Toggle Bluetooth ON
//                    StepView(
//                        stepNumber: 3,
//                        title: "Turn Bluetooth ON",
//                        isActive: currentStep >= 2
//                    ) {
//                        // Mock Bluetooth settings page
//                        VStack(spacing: 0) {
//                            // Bluetooth header
//                            HStack {
//                                Image(systemName: "chevron.left")
//                                    .font(.system(size: 18, weight: .medium))
//                                    .foregroundColor(.blue)
//                                Text("Bluetooth")
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                Spacer()
//                            }
//                            .padding()
//                            .background(Color(.systemGray6))
//                            
//                            // Bluetooth toggle
//                            HStack {
//                                VStack(alignment: .leading) {
//                                    Text("Bluetooth")
//                                        .font(.body)
//                                        .foregroundColor(.primary)
//                                    if !bluetoothEnabled {
//                                        Text("Off")
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                                
//                                Spacer()
//                                
//                                // Toggle switch
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 16)
//                                        .fill(bluetoothEnabled ? Color.green : Color.gray)
//                                        .frame(width: 50, height: 30)
//                                    
//                                    Circle()
//                                        .fill(Color.white)
//                                        .frame(width: 26, height: 26)
//                                        .offset(x: bluetoothEnabled ? 10 : -10)
//                                        .animation(.easeInOut(duration: 0.3), value: bluetoothEnabled)
//                                }
//                                .scaleEffect(currentStep >= 2 && pulseAnimation ? 1.1 : 1.0)
//                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)
//                            }
//                            .padding()
//                            .background(Color(.systemBackground))
//                            
//                            // Devices list (when enabled)
//                            if bluetoothEnabled {
//                                VStack {
//                                    Divider()
//                                    HStack {
//                                        Text("MY DEVICES")
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//                                        Spacer()
//                                    }
//                                    .padding(.horizontal)
//                                    .padding(.top, 8)
//                                    
//                                    Text("Searching for devices...")
//                                        .font(.body)
//                                        .foregroundColor(.gray)
//                                        .padding()
//                                }
//                                .background(Color(.systemBackground))
//                                .transition(.opacity)
//                            }
//                        }
//                        .frame(width: 280)
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                        )
//                        
//                        // Pointing finger for toggle
//                        if currentStep >= 2 && !bluetoothEnabled {
//                            HStack {
//                                Spacer()
//                                Image(systemName: "hand.point.up.left.fill")
//                                    .font(.system(size: 24))
//                                    .foregroundColor(.orange)
//                                    .offset(x: 20, y: -50)
//                                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
//                                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulseAnimation)
//                            }
//                        }
//                    }
//                    
//                    // Step 4: Success
//                    if currentStep >= 3 {
//                        VStack(spacing: 16) {
//                            Image(systemName: "checkmark.circle.fill")
//                                .font(.system(size: 60))
//                                .foregroundColor(.green)
//                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
//                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
//                            
//                            Text("Bluetooth is now ON!")
//                                .font(.title3)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.green)
//                            
//                            Text("You can now return to the app")
//                                .font(.body)
//                                .foregroundColor(.secondary)
//                        }
//                        .padding()
//                        .background(Color.green.opacity(0.1))
//                        .cornerRadius(12)
//                        .transition(.scale.combined(with: .opacity))
//                    }
//                }
//                
//                // Control buttons
//                HStack(spacing: 16) {
//                    Button("Restart") {
//                        restart()
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 12)
//                    .background(Color.gray.opacity(0.2))
//                    .foregroundColor(.primary)
//                    .cornerRadius(8)
//                    
//                    if currentStep < 3 {
//                        Button("Next Step") {
//                            nextStep()
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 12)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                    } else {
//                        Button("Open Settings") {
//                            openSettings()
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 12)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                    }
//                }
//                .padding(.top)
//            }
//            .padding()
//        }
//        .onAppear {
//            pulseAnimation = true
//            startAutoPlay()
//        }
//    }
//    
//    private func nextStep() {
//        if currentStep < 3 {
//            currentStep += 1
//            if currentStep == 3 {
//                // Auto-enable Bluetooth when reaching step 3
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    bluetoothEnabled = true
//                }
//            }
//        }
//    }
//    
//    private func restart() {
//        currentStep = 0
//        bluetoothEnabled = false
//        isAutoPlaying = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            startAutoPlay()
//        }
//    }
//    
//    private func startAutoPlay() {
//        guard !isAutoPlaying else { return }
//        isAutoPlaying = true
//        
//        // Auto-progress through steps
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            if currentStep == 0 { currentStep = 1 }
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
//            if currentStep == 1 { currentStep = 2 }
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
//            if currentStep == 2 {
//                bluetoothEnabled = true
//                currentStep = 3
//            }
//        }
//    }
//    
//    private func openSettings() {
//        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
//            UIApplication.shared.open(settingsUrl)
//        }
//    }
//}
//
//struct StepView<Content: View>: View {
//    let stepNumber: Int
//    let title: String
//    let isActive: Bool
//    let content: Content
//    
//    init(stepNumber: Int, title: String, isActive: Bool, @ViewBuilder content: () -> Content) {
//        self.stepNumber = stepNumber
//        self.title = title
//        self.isActive = isActive
//        self.content = content()
//    }
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            HStack {
//                Circle()
//                    .fill(isActive ? Color.blue : Color.gray.opacity(0.3))
//                    .frame(width: 24, height: 24)
//                    .overlay(
//                        Text("\(stepNumber)")
//                            .font(.caption)
//                            .fontWeight(.medium)
//                            .foregroundColor(isActive ? .white : .gray)
//                    )
//                
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(isActive ? .primary : .gray)
//                
//                Spacer()
//            }
//            
//            content
//                .opacity(isActive ? 1.0 : 0.6)
//                .scaleEffect(isActive ? 1.0 : 0.95)
//                .animation(.easeInOut(duration: 0.3), value: isActive)
//        }
//        .padding()
//        .background(isActive ? Color.blue.opacity(0.05) : Color.clear)
//        .cornerRadius(12)
//    }
//}
//
//struct SettingsRowView: View {
//    let icon: String
//    let title: String
//    let color: Color
//    var isHighlighted: Bool = false
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 6)
//                    .fill(color)
//                    .frame(width: 24, height: 24)
//                
//                Image(systemName: icon)
//                    .font(.system(size: 12))
//                    .foregroundColor(.white)
//            }
//            
//            Text(title)
//                .font(.body)
//                .foregroundColor(.primary)
//            
//            Spacer()
//            
//            Image(systemName: "chevron.right")
//                .font(.system(size: 12))
//                .foregroundColor(.gray)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//        .background(isHighlighted ? Color.blue.opacity(0.1) : Color.clear)
//        .overlay(
//            Rectangle()
//                .fill(Color.gray.opacity(0.3))
//                .frame(height: 0.5)
//                .offset(y: 20)
//        )
//    }
//}
//
//struct BluetoothSettingsGuideView_Previews: PreviewProvider {
//    static var previews: some View {
//        BluetoothSettingsGuideView()
//    }
//}

import SwiftUI

struct BluetoothSettingsGuideView: View {
    @State private var currentStep = 0
    @State private var bluetoothEnabled = false
    @State private var pulseAnimation = false
    @State private var isAutoScrolling = false
    @State private var animationCompleted = false
    
    // Auto-scroll timing
    private let stepDuration: Double = 3.0
    private let animationDelay: Double = 0.5

    var body: some View {
        VStack(spacing: 20) {
            // Header with enhanced styling
            VStack(spacing: 8) {
                Text("How to Turn On Bluetooth")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Follow these steps to enable Bluetooth")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()

            // Enhanced Step Indicator
            HStack(spacing: 12) {
                ForEach(0..<4) { step in
                    ZStack {
                        Circle()
                            .fill(currentStep >= step ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .scaleEffect(currentStep == step ? 1.3 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                        
                        // Checkmark for completed steps
                        if currentStep > step {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    // Connecting line
                    if step < 3 {
                        Rectangle()
                            .fill(currentStep > step ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 20, height: 2)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
            }
            .padding(.horizontal)

            // Steps as swipeable pages
            TabView(selection: $currentStep) {
                Step1View(pulse: $pulseAnimation, animationCompleted: $animationCompleted).tag(0)
                Step2View(pulse: $pulseAnimation, animationCompleted: $animationCompleted).tag(1)
                Step3View(pulse: $pulseAnimation, bluetoothEnabled: $bluetoothEnabled, animationCompleted: $animationCompleted).tag(2)
                Step4View(pulse: $pulseAnimation, animationCompleted: $animationCompleted).tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.5), value: currentStep)
            .onChange(of: currentStep) { _ in
                startStepAnimation()
            }
            
            // Progress indicator
            HStack {
                Text("Step \(currentStep + 1) of 4")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isAutoScrolling {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Auto-advancing...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            startStepAnimation()
        }
    }
    
    private func startStepAnimation() {
        // Reset animation state
        pulseAnimation = false
        animationCompleted = false
        
        // Start pulse animation with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
            withAnimation {
                pulseAnimation = true
            }
        }
        
        // Handle step-specific logic
        handleStepLogic()
        
        // Start auto-scroll timer (except for last step)
        if currentStep < 3 {
            isAutoScrolling = true
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
                if currentStep < 3 {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentStep += 1
                    }
                }
                isAutoScrolling = false
            }
        }
    }
    
    private func handleStepLogic() {
        switch currentStep {
        case 2:
            // Auto-enable bluetooth in step 3 after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    bluetoothEnabled = true
                }
                animationCompleted = true
            }
        case 3:
            // Mark final step as completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                animationCompleted = true
            }
        default:
            // Mark other steps as completed after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                animationCompleted = true
            }
        }
    }
}

struct Step1View: View {
    @Binding var pulse: Bool
    @Binding var animationCompleted: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("Step 1: Open Settings")
                .font(.headline)
                .foregroundColor(.primary)

            ZStack {
                // Phone background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.05))
                    .frame(width: 220, height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )

                VStack(spacing: 12) {
                    // Settings icon with enhanced animation
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                colors: [Color.gray, Color.gray.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 55, height: 55)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        Image(systemName: "gear")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(pulse ? 360 : 0))
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: pulse)
                    }
                    .scaleEffect(pulse ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)

                    Text("Settings")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }

                // Animated pointer with bounce effect
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.orange)
                    .offset(x: 50, y: 40)
                    .scaleEffect(pulse ? 1.3 : 1.0)
                    .rotationEffect(.degrees(pulse ? -5 : 5))
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
            }
            
            if animationCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Tap completed!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: animationCompleted)
            }
        }
        .padding()
    }
}

struct Step2View: View {
    @Binding var pulse: Bool
    @Binding var animationCompleted: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("Step 2: Find Bluetooth")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 0) {
                // Settings header
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))

                VStack(spacing: 1) {
                    SettingsRowView(icon: "airplane", title: "Airplane Mode", color: .orange)
                    SettingsRowView(icon: "wifi", title: "Wi-Fi", color: .blue)
                    SettingsRowView(icon: "bluetooth", title: "Bluetooth", color: .blue, isHighlighted: true, pulse: pulse)
                    SettingsRowView(icon: "antenna.radiowaves.left.and.right", title: "Cellular", color: .green)
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .frame(width: 280)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3))
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            
            if animationCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Bluetooth found!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: animationCompleted)
            }
        }
        .padding()
    }
}

struct Step3View: View {
    @Binding var pulse: Bool
    @Binding var bluetoothEnabled: Bool
    @Binding var animationCompleted: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("Step 3: Turn Bluetooth ON")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 0) {
                // Bluetooth header
                HStack {
                    Text("Bluetooth")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))

                VStack(spacing: 16) {
                    // Bluetooth toggle
                    HStack {
                        Text("Bluetooth")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        // Enhanced toggle switch
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(bluetoothEnabled ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 55, height: 32)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(bluetoothEnabled ? Color.green.opacity(0.5) : Color.gray.opacity(0.5), lineWidth: 1)
                                )

                            Circle()
                                .fill(Color.white)
                                .frame(width: 28, height: 28)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                .offset(x: bluetoothEnabled ? 11 : -11)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: bluetoothEnabled)
                        }
                        .scaleEffect(pulse && !bluetoothEnabled ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                    }
                    .padding(.horizontal)

                    // Status message
                    if bluetoothEnabled {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "bluetooth")
                                    .foregroundColor(.blue)
                                    .scaleEffect(1.0)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: bluetoothEnabled)
                                
                                Text("Bluetooth is ON")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .fontWeight(.medium)
                            }
                            
                            Text("Searching for devices...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: bluetoothEnabled)
                    }
                }
                .padding(.bottom)
            }
            .frame(width: 300)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3))
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

            // Pointer for toggle
            if !bluetoothEnabled {
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.orange)
                    .offset(x: 50, y: -30)
                    .scaleEffect(pulse ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulse)
            }
        }
        .padding()
    }
}

struct Step4View: View {
    @Binding var pulse: Bool
    @Binding var animationCompleted: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Success animation
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulse ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
                
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(.green)
                    .scaleEffect(pulse ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
            }

            VStack(spacing: 12) {
                Text("Bluetooth is now ON!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                Text("You can now pair with devices and return to your app")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Success indicator
            if animationCompleted {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "bluetooth")
                            .foregroundColor(.blue)
                        Text("Ready to connect")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: animationCompleted)
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(16)
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let color: Color
    var isHighlighted: Bool = false
    var pulse: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            // Icon with enhanced styling
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 26, height: 26)
                    .shadow(color: color.opacity(0.3), radius: 1, x: 0, y: 1)

                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleEffect(isHighlighted && pulse ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)

            Text(title)
                .font(.body)
                .fontWeight(isHighlighted ? .medium : .regular)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            isHighlighted ?
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                startPoint: .leading,
                endPoint: .trailing
            ) :
            LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
        )
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.5)
                .offset(y: 24)
        )
    }
}

#Preview {
    BluetoothSettingsGuideView()
}
