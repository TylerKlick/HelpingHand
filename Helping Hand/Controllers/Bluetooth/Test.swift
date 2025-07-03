import SwiftUI

struct DeviceListView: View {
    @ObservedObject var manager: CentralManager = .init()

    var body: some View {
        NavigationView {
            VStack {
                if manager.isBluetoothOn {
                    List(manager.discoveredPeripherals, id: \.identifier) { peripheral in
                        Button(action: {
                            manager.connect(to: peripheral)
                        }) {
                            HStack {
                                Text(peripheral.name ?? "Unnamed")
                                Spacer()
                                Image(systemName: "arrow.right.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("Bluetooth is Off or Initializing...")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nearby Devices")
        }
    }
}
