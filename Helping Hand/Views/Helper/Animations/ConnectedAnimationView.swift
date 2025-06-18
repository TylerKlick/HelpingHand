import SwiftUI

struct ConnectedAnimationView: View {
    let numberOfBars = 20
    let barWidth: CGFloat = 10
    let maxBarHeight: CGFloat = 80
    let spacing: CGFloat = 6

    let frameCount = 30
    let waveFrequency: CGFloat = 2
    let waveAmplitude: CGFloat = 1.0

    @State private var currentFrame: Int = 0
    @State private var pulse = false

    private let precomputedFrames: [[CGFloat]]

    private let timer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

    init() {
        var frames: [[CGFloat]] = []

        for frame in 0..<frameCount {
            let phase = CGFloat(frame) / CGFloat(frameCount) * 2 * .pi
            var barHeights: [CGFloat] = []

            for i in 0..<numberOfBars {
                let x = CGFloat(i) / CGFloat(numberOfBars - 1)
                let y = (sin(phase + x * waveFrequency * 2 * .pi) + 1) / 2
                barHeights.append(y)
            }

            frames.append(barHeights)
        }

        self.precomputedFrames = frames
    }

    var body: some View {
        
        VStack {
            ZStack {
                HStack(spacing: spacing) {
                    ForEach(0..<numberOfBars, id: \.self) { i in
                        let heightRatio = precomputedFrames[currentFrame][i]
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray)
                            .frame(width: barWidth, height: maxBarHeight * heightRatio)
                            .opacity(0.4)
                    }
                }
                .frame(height: maxBarHeight)
                .padding(.horizontal, 20)
                
                Text("🖐️")
                    .font(.system(size: 80))
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
                    .onAppear {
                        pulse = true
                    }
            }
            .frame(height: 150)
            .onReceive(timer) { _ in
                currentFrame = (currentFrame + 1) % frameCount
            }
            
            Text("Device Connected!")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ConnectedAnimationView()
        .padding()
}
