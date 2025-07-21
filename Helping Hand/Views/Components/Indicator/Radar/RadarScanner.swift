//import SwiftUI
//
//struct RadarView: Animatable, View {
//    let scannerSize: CGFloat = 250
//    let color: Color = .green
//    let duration: Double = 1.5
//    var onRotationChange: (CGFloat) -> Void
//    
//    var rotationData: CGFloat {
//        get { rotation }
//        set {
//            rotation = newValue
//        }
//    }
//
//    
//    @State private var rotation: Double = 0
//    
//    var body: some View {
//        VStack {
//            ZStack {
//                Circle()
//                    .stroke(color.opacity(0.3), lineWidth: 2)
//                    .frame(width: scannerSize, height: scannerSize)
//                
//                Rectangle()
//                    .frame(width: 4, height: scannerSize / 2)
//                    .offset(y: -scannerSize / 4)
//                    .keyframeAnimator(
//                        initialValue: rotation,
//                        repeating: true
//                    ) { rect, angle in
//                        rect.rotationEffect(.degrees(angle))
//                    } keyframes: { _ in
//                        KeyframeTrack(\.self) {
//                            LinearKeyframe(rotation + 360, duration: duration)
//                        }
//                    }
//                    .foregroundColor(color)
//                    .onChange(of: rotation) { _, newValue in
//                        // Update rotation state continuously
//                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//                            rotation += 1
//                        }
//                    }
//            }
//            
//            Text("Rotation: \(Int(rotation.truncatingRemainder(dividingBy: 360)))°")
//                .font(.monospaced(.body)())
//                .foregroundColor(color)
//                .padding(.top, 20)
//        }
//        .onAppear {
//            rotation = 360
//        }
//    }
//}
//
//#Preview {
//    RadarView()
//}
