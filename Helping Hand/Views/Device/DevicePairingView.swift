import SwiftUI
import Accelerate

// MARK: - Spectrogram ViewModel
nonisolated class SpectrogramViewModel: ObservableObject {
    @Published private(set) var spectrogram: [[Float]] = []

    private var pendingSpectrogram: [[Float]] = []
    private var sampleBuffer: [Float] = []

    private let windowSize = 128
    private let hopSize = 64
    private let fftSize = 128
    private let maxFrames = 100
    private var window: [Float]

    init() {
        window = vDSP.window(ofType: Float.self,
                             usingSequence: .hanningDenormalized,
                             count: windowSize,
                             isHalfWindow: false)
    }

    func pushSample(_ sample: Float) {
        sampleBuffer.append(sample)
        checkAndProcess()
    }

    func pushSamples(_ samples: [Float]) {
        sampleBuffer.append(contentsOf: samples)
        checkAndProcess()
    }

    private func checkAndProcess() {
        var updated = false
        while sampleBuffer.count >= windowSize {
            let frame = Array(sampleBuffer.prefix(windowSize))
            sampleBuffer.removeFirst(hopSize)
            let result = processFrame(frame)
            pendingSpectrogram.append(result)
            updated = true
        }

        if updated {
            spectrogram.append(contentsOf: pendingSpectrogram)
            pendingSpectrogram.removeAll()

            if spectrogram.count > maxFrames {
                spectrogram.removeFirst(spectrogram.count - maxFrames)
            }
        }
    }

    private func processFrame(_ frame: [Float]) -> [Float] {
        var windowed = [Float](repeating: 0, count: windowSize)
        vDSP.multiply(frame, window, result: &windowed)

        var real = windowed
        var imag = [Float](repeating: 0, count: fftSize)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imag)
        let log2n = vDSP_Length(log2(Float(fftSize)))
        let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))!
        vDSP_fft_zip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
        vDSP_destroy_fftsetup(fftSetup)

        var magnitudes = [Float](repeating: 0, count: fftSize / 2)
        vDSP.absolute(splitComplex, result: &magnitudes)

        var normalized = [Float](repeating: 0, count: fftSize / 2)
        var maxMag: Float = 1e-6
        vDSP_maxv(magnitudes, 1, &maxMag, vDSP_Length(fftSize / 2))
        vDSP.divide(magnitudes, maxMag, result: &normalized)

        return normalized
    }
}
// MARK: - Spectrogram View
struct SpectrogramView: View {
    @ObservedObject var viewModel: SpectrogramViewModel

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let cols = viewModel.spectrogram.count
                let rows = viewModel.spectrogram.first?.count ?? 0
                guard cols > 0, rows > 0 else { return }

                let cellWidth = size.width / CGFloat(cols)
                let cellHeight = size.height / CGFloat(rows)

                for (x, column) in viewModel.spectrogram.enumerated() {
                    for (y, value) in column.enumerated() {
                        let color = Color(hue: 0.66 - Double(value) * 0.66,
                                          saturation: 1,
                                          brightness: Double(value))
                        let rect = CGRect(x: CGFloat(x) * cellWidth,
                                          y: size.height - CGFloat(y + 1) * cellHeight,
                                          width: cellWidth,
                                          height: cellHeight)
                        context.fill(Path(rect), with: .color(color))
                    }
                }
            }
        }
    }
}

// MARK: - Demo Preview with Timer
struct BontentView: View {
    @StateObject private var viewModel = BluetoothManager.singleton.viewModelSpectra

    var body: some View {
        VStack {
            Text("Live Spectrogram")
                .font(.title2)
                .padding(.top)

            SpectrogramView(viewModel: viewModel)
                .frame(maxWidth: .infinity)
                .aspectRatio(2, contentMode: .fit)
                .padding()
                .background(Color.black)
                .cornerRadius(16)
                .shadow(radius: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .padding(.horizontal)

            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}
