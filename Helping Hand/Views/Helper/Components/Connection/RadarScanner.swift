////import SwiftUI
////
////struct RadarMark: Identifiable {
////    let id = UUID()
////    var distance: Double  // Normalized (0-1)
////    var angle: Double     // Degrees
////    var lastIlluminated: Date?  // Timestamp when last illuminated
////}
////
////struct RadarView: View {
////    @State private var marks: [RadarMark] = []
////    @State private var sweepAngle: Double = 0
////    @State private var lastUpdate = Date()
////    private let maxRadius: CGFloat = 150
////    private let sweepSpeed: Double = 180  // Degrees per second
////    private let fadeDuration: Double = 2.0  // Blip fade duration in seconds
////    
////    // Timer for smooth animation (60fps)
////    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
////    
////    var body: some View {
////        VStack {
////            // Radar Display
////            ZStack {
////                // Background
////                radarBackground
////                
////                // Dynamic rings
////                radarRings
////                
////                // Radar sweep with gradient
////                sweepEffect
////                
////                // Radar blips
////                ForEach($marks) { $mark in
////                    markView(for: mark)
////                }
////            }
////            .frame(width: maxRadius * 2, height: maxRadius * 2)
////            .clipShape(Circle())
////            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 0)
////            .padding(.bottom, 20)
////            
////            // Controls
////            controlPanel
////        }
////        .padding()
////        .background(Color.black)
////        .onReceive(timer) { currentTime in
////            updateSweep(currentTime: currentTime)
////        }
////    }
////    
////    // MARK: - Components
////    
////    private var radarBackground: some View {
////        Circle()
////            .fill(
////                RadialGradient(
////                    gradient: Gradient(colors: [
////                        Color.black.opacity(0.8),
////                        Color(red: 0.05, green: 0.15, blue: 0.3)
////                    ]),
////                    center: .center,
////                    startRadius: 0,
////                    endRadius: maxRadius
////                )
////            )
////            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
////                     )
////    }
////    
////    private var radarRings: some View {
////        ForEach(1...3, id: \.self) { index in
////            let radius = maxRadius * CGFloat(index) / 3
////            Circle()
////                .stroke(
////                    LinearGradient(
////                        gradient: Gradient(colors: [
////                            .white.opacity(0.05),
////                            .white.opacity(0.15),
////                            .white.opacity(0.05)
////                        ]),
////                        startPoint: .topLeading,
////                        endPoint: .bottomTrailing
////                    ),
////                    lineWidth: 0.5
////                )
////                .frame(width: radius * 2, height: radius * 2)
////        }
////    }
////    
////    private var sweepEffect: some View {
////        GeometryReader { geometry in
////            let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
////            
////            // Sweep gradient with trail effect
////            Path { path in
////                path.move(to: center)
////                let radians = sweepAngle * .pi / 180
////                path.addLine(to: CGPoint(
////                    x: center.x + maxRadius * CGFloat(cos(radians)),
////                    y: center.y + maxRadius * CGFloat(sin(radians))
////                ))
////            }
////            .stroke(
////                LinearGradient(
////                    gradient: Gradient(stops: [
////                        .init(color: .clear, location: 0),
////                        .init(color: .green.opacity(0.8), location: 0.1),
////                        .init(color: .green.opacity(0.4), location: 0.4),
////                        .init(color: .green.opacity(0.1), location: 0.8),
////                        .init(color: .clear, location: 1)
////                    ]),
////                    startPoint: .leading,
////                    endPoint: .trailing
////                ),
////                lineWidth: 1.5
////            )
////        }
////    }
////    
////    private func markView(for mark: RadarMark) -> some View {
////        let radians = mark.angle * .pi / 180
////        let radius = maxRadius * CGFloat(mark.distance)
////        let x = radius * cos(radians)
////        let y = radius * sin(radians)
////        
////        // Calculate blip opacity based on last illumination time
////        let opacity: Double = {
////            guard let lastIlluminated = mark.lastIlluminated else { return 0 }
////            let elapsed = Date().timeIntervalSince(lastIlluminated)
////            return max(0, 1 - (elapsed / fadeDuration))
////        }()
////        
////        return Circle()
////            .fill(LinearGradient(
////                gradient: Gradient(colors: [.green, .teal]),
////                startPoint: .topLeading,
////                endPoint: .bottomTrailing
////            ))
////            .frame(width: 12, height: 12)
////            .overlay(Circle().stroke(Color.white, lineWidth: 1))
////            .offset(x: x, y: y)
////            .opacity(opacity)
////            .blur(radius: 2 - (2 * opacity))  // Blur increases as it fades
////    }
////    
////    private var controlPanel: some View {
////        HStack(spacing: 30) {
////            Button(action: addRandomMark) {
////                Image(systemName: "plus.circle.fill")
////                    .font(.title)
////            }
////            
////            Button(action: removeLastMark) {
////                Image(systemName: "minus.circle.fill")
////                    .font(.title)
////            }
////            
////            Button(action: removeAllMarks) {
////                Image(systemName: "trash.circle.fill")
////                    .font(.title)
////            }
////        }
////        .foregroundColor(.white)
////        .padding(.top, 10)
////    }
////    
////    // MARK: - Logic
////    
////    private func updateSweep(currentTime: Date) {
////        // Calculate angle increment based on time elapsed
////        let delta = currentTime.timeIntervalSince(lastUpdate)
////        sweepAngle = (sweepAngle + (sweepSpeed * delta)).truncatingRemainder(dividingBy: 360)
////        lastUpdate = currentTime
////        
////        // Update illumination status for marks
////        for index in marks.indices {
////            let angleDifference = abs(marks[index].angle - sweepAngle).truncatingRemainder(dividingBy: 360)
////            let minAngleDifference = min(angleDifference, 360 - angleDifference)
////            
////            // Illuminate marks when sweep is close (within 5 degrees)
////            if minAngleDifference < 5 {
////                marks[index].lastIlluminated = currentTime
////            }
////        }
////    }
////    
////    // MARK: - Actions
////    
////    private func addRandomMark() {
////        let newMark = RadarMark(
////            distance: Double.random(in: 0.1...0.95),
////            angle: Double.random(in: 0...360),
////            lastIlluminated: nil  // Will be illuminated when sweep passes
////        )
////        marks.append(newMark)
////    }
////    
////    private func removeLastMark() {
////        guard !marks.isEmpty else { return }
////        marks.removeLast()
////    }
////    
////    private func removeAllMarks() {
////        marks.removeAll()
////    }
////}
////
////struct RadarView_Previews: PreviewProvider {
////    static var previews: some View {
////        RadarView()
////    }
////}
//
//import SwiftUI
//
//struct RadarMark: Identifiable {
//    let id = UUID()
//    var distance: Double
//    var angle: Double
//    var lastIlluminated: Date?
//}
//
//struct RadarView: View {
//    @State private var marks: [RadarMark] = []
//    @State private var sweepAngle: Double = 0
//    private let radius: CGFloat = 150
//    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
//    
//    var body: some View {
//        VStack {
//            ZStack {
//                // Background circle
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: radius * 2, height: radius * 2)
//                
//                // Sweep line
//                Circle()
//                    .trim(from: 0, to: 0.15)
//                    .stroke(lineWidth: radius / 2 )
//                    .fill(.green)
//                    .frame(width: radius * 2, height: radius * 2)
//                    .rotationEffect(.degrees(sweepAngle - 35))
//                
//                // Scanner line
//                Rectangle()
//                    .frame(width: 4, height: (self.radius / 2))
//                    .offset(x: 0, y: -self.radius / 4)
//                    .rotationEffect(.degrees(self.sweepAngle))
//                    .foregroundColor(.green)
//                
//                // Blips
//                ForEach(marks) { mark in
//                    blipView(for: mark)
//                }
//            }
//            .background(Color.black)
//            .clipShape(Circle())
//            
//            // Controls
//            HStack(spacing: 20) {
//                Button("Add") { addRandomMark() }
//                Button("Remove") { removeLastMark() }
//                Button("Clear") { marks.removeAll() }
//            }
//            .foregroundColor(.white)
//            .padding()
//        }
//        .background(Color.black)
//        .onReceive(timer) { _ in
//            sweepAngle = (sweepAngle + 3).truncatingRemainder(dividingBy: 360)
//            updateBlips()
//        }
//    }
//    
//    private func blipView(for mark: RadarMark) -> some View {
//        let radians = mark.angle * .pi / 180
//        let r = radius * mark.distance
//        let x = r * cos(radians)
//        let y = r * sin(radians)
//        
//        let opacity: Double = {
//            guard let lastIlluminated = mark.lastIlluminated else { return 0 }
//            let elapsed = Date().timeIntervalSince(lastIlluminated)
//            return max(0, 1 - (elapsed / 2.0))
//        }()
//        
//        return Circle()
//            .fill(Color.green)
//            .frame(width: 8, height: 8)
//            .offset(x: x, y: y)
//            .opacity(opacity)
//    }
//    
//    private func updateBlips() {
//        for i in marks.indices {
//            let angleDiff = abs(marks[i].angle - sweepAngle).truncatingRemainder(dividingBy: 360)
//            let minDiff = min(angleDiff, 360 - angleDiff)
//            if minDiff < 5 {
//                marks[i].lastIlluminated = Date()
//            }
//        }
//    }
//    
//    private func addRandomMark() {
//        marks.append(RadarMark(
//            distance: Double.random(in: 0.2...0.9),
//            angle: Double.random(in: 0...360),
//            lastIlluminated: nil
//        ))
//    }
//    
//    private func removeLastMark() {
//        if !marks.isEmpty { marks.removeLast() }
//    }
//}
//
//struct RadarView_Previews: PreviewProvider {
//    static var previews: some View {
//        RadarView()
//    }
//}

import SwiftUI

struct RadarMark: Identifiable {
    let id = UUID()
    var distance: Double  // Normalized (0-1)
    var angle: Double     // Degrees
    var lastIlluminated: Date?  // Timestamp when last illuminated
}

struct RadarView: View {
    @State private var marks: [RadarMark] = []
    @State private var sweepAngle: Double = 0
    @State private var lastUpdate = Date()
    private let maxRadius: CGFloat = 160
    private let sweepSpeed: Double = 90  // Degrees per second
    private let fadeDuration: Double = 3.0  // Blip fade duration in seconds
    
    // Timer for smooth animation (60fps)
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 30) {
            // Radar Display
            ZStack {
                // Outer neumorphic container
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.12, green: 0.12, blue: 0.12),
                                Color(red: 0.08, green: 0.08, blue: 0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear,
                                        Color.black.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 6, y: 6)
                    .shadow(color: .white.opacity(0.05), radius: 12, x: -6, y: -6)
                    .frame(width: (maxRadius + 20) * 2, height: (maxRadius + 20) * 2)
                
                // Inner radar display
                ZStack {
                    // Background
                    radarBackground
                    
                    // Dynamic rings
                    radarRings
                    
                    // Radar sweep with gradient
                    sweepEffect
                    
                    // Radar blips
                    ForEach($marks) { $mark in
                        markView(for: mark)
                    }
                    
                    // Center dot
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 6, height: 6)
                        .shadow(color: .cyan, radius: 4)
                }
                .frame(width: maxRadius * 2, height: maxRadius * 2)
                .clipShape(Circle())
            }
            
            // Controls
            controlPanel
        }
        .padding(40)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.05, green: 0.05, blue: 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onReceive(timer) { currentTime in
            updateSweep(currentTime: currentTime)
        }
    }
    
    // MARK: - Components
    
    private var radarBackground: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.02, green: 0.08, blue: 0.12),
                        Color(red: 0.01, green: 0.04, blue: 0.08),
                        Color.black
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: maxRadius
                )
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.2),
                                Color.blue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    private var radarRings: some View {
        ForEach(1...3, id: \.self) { index in
            let radius = maxRadius * CGFloat(index) / 3
            Circle()
                .stroke(Color.cyan.opacity(0.15), lineWidth: 0.5)
                .frame(width: radius * 2, height: radius * 2)
        }
    }
    
    private var crosshairs: some View {
        ZStack {
            // Vertical line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.cyan.opacity(0.3),
                            Color.cyan.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1, height: maxRadius * 2)
            
            // Horizontal line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.cyan.opacity(0.3),
                            Color.cyan.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: maxRadius * 2, height: 1)
        }
    }
    
    private var sweepEffect: some View {
        ZStack {
            // Sweep trail (fading arc)
            ForEach(0..<60, id: \.self) { i in
                let trailAngle = sweepAngle - Double(i) * 1.5
                let opacity = 1.0 - (Double(i) / 60.0)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.cyan.opacity(opacity * 0.4),
                                Color.cyan.opacity(opacity * 0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2, height: maxRadius)
                    .offset(y: -maxRadius / 2)
                    .rotationEffect(.degrees(trailAngle))
            }
            
            // Sweep arm (bright line)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.cyan,
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: maxRadius)
                .offset(y: -maxRadius / 2)
                .rotationEffect(.degrees(sweepAngle))
                .shadow(color: .cyan, radius: 4)
        }
    }
    
    private func markView(for mark: RadarMark) -> some View {
        let radians = (mark.angle - 90) * .pi / 180  // Adjust for 0° being at top
        let radius = maxRadius * CGFloat(mark.distance)
        let x = radius * cos(radians)
        let y = radius * sin(radians)
        
        // Calculate blip opacity based on last illumination time
        let opacity: Double = {
            guard let lastIlluminated = mark.lastIlluminated else { return 0 }
            let elapsed = Date().timeIntervalSince(lastIlluminated)
            return max(0, 1 - (elapsed / fadeDuration))
        }()
        
        return ZStack {
            // Outer glow rings
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.cyan.opacity(0.1 * opacity))
                    .frame(width: CGFloat(20 + i * 8), height: CGFloat(20 + i * 8))
                    .blur(radius: CGFloat(2 + i))
            }
            
            // Main blip with neumorphic style
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.9),
                            Color.blue.opacity(0.7),
                            Color.cyan.opacity(0.5)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 6
                    )
                )
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.clear,
                                    Color.black.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .cyan.opacity(0.8), radius: 6)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
        }
        .offset(x: x, y: y)
        .opacity(opacity)
        .scaleEffect(0.5 + (opacity * 0.5))  // Scale with opacity
    }
    
    private var controlPanel: some View {
        HStack(spacing: 40) {
            controlButton(
                icon: "plus",
                label: "Add Target",
                action: addRandomMark
            )
            
            controlButton(
                icon: "minus",
                label: "Remove",
                action: removeLastMark
            )
            
            controlButton(
                icon: "trash",
                label: "Clear All",
                action: removeAllMarks
            )
        }
    }
    
    private func controlButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.15, green: 0.15, blue: 0.15),
                                    Color(red: 0.08, green: 0.08, blue: 0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),
                                            Color.clear,
                                            Color.black.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 3, y: 3)
                        .shadow(color: .white.opacity(0.05), radius: 6, x: -3, y: -3)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.cyan)
                        .shadow(color: .cyan, radius: 2)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: marks.count)
    }
    
    // MARK: - Logic
    
    private func updateSweep(currentTime: Date) {
        // Calculate angle increment based on time elapsed
        let delta = currentTime.timeIntervalSince(lastUpdate)
        sweepAngle = (sweepAngle + (sweepSpeed * delta)).truncatingRemainder(dividingBy: 360)
        lastUpdate = currentTime
        
        // Update illumination status for marks
        for index in marks.indices {
            let markAngle = marks[index].angle
            let normalizedSweepAngle = sweepAngle.truncatingRemainder(dividingBy: 360)
            
            // Calculate angular difference
            let angleDifference = abs(markAngle - normalizedSweepAngle)
            let minAngleDifference = min(angleDifference, 360 - angleDifference)
            
            // Illuminate marks when sweep is close (within 4 degrees)
            if minAngleDifference < 4 {
                marks[index].lastIlluminated = currentTime
            }
        }
    }
    
    // MARK: - Actions
    
    private func addRandomMark() {
        let newMark = RadarMark(
            distance: Double.random(in: 0.2...0.9),
            angle: Double.random(in: 0...360),
            lastIlluminated: nil  // Will be illuminated when sweep passes
        )
        marks.append(newMark)
    }
    
    private func removeLastMark() {
        guard !marks.isEmpty else { return }
        marks.removeLast()
    }
    
    private func removeAllMarks() {
        marks.removeAll()
    }
}

struct RadarView_Previews: PreviewProvider {
    static var previews: some View {
        RadarView()
            .preferredColorScheme(.dark)
    }
}
