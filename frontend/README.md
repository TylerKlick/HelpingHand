# Helping Hands - Frontend
---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) v20+
- [Expo CLI](https://docs.expo.dev/get-started/installation/)
- iOS: Xcode
- Android: Android Studio 
- Physical device required for BLE testing 

### Installation

```bash
cd frontend
npm install
```

### Running the App

```bash
# Start Expo dev server
npx expo start

# Run on iOS device/simulator
npx expo run:ios

# Run on Android device/emulator
npx expo run:android

# Run in browser (UI preview only — no BLE)
npx expo start --web
```
---

## Project Structure

```
frontend/
├── App.tsx                          # App entry point
├── app.json                         # Expo configuration
├── package.json
├── tsconfig.json
├── assets/                          # Icons and splash screen images
└── src/
    ├── navigation/
    │   └── AppNavigator.tsx          # All navigation 
    ├── screens/
    │   ├── WelcomeScreen.tsx         # Onboarding splash
    │   ├── ReadyToConnectScreen.tsx  # Pre-connection device info
    │   ├── SearchingScreen.tsx       # BLE scanning state
    │   ├── ConnectedScreen.tsx       # Connection success
    │   ├── DashboardScreen.tsx       # Main hub
    │   ├── MyGesturesScreen.tsx      # Gesture list + toggle
    │   ├── GestureShopScreen.tsx     # Pre-configured gesture library
    │   ├── CreateGestureScreen.tsx   # Custom gesture builder
    │   ├── HealthMonitorScreen.tsx   # Device health metrics
    │   ├── SettingsScreen.tsx        # App settings
    │   ├── HelpScreen.tsx           # Help topics
    │   ├── UpdatesScreen.tsx         # Firmware update status
    │   └── GamesScreen.tsx           # Placeholder for training games
    ├── services/
    │   └── BLEService.ts             # Bluetooth Low Energy manager
    └── theme/
        ├── colors.ts                 # NC State color palette
        └── index.ts                  # Theme exports
```

---

## Architecture

### Tech Stack

| Layer        | Technology                                  |
|--------------|---------------------------------------------|
| Framework    | React Native (Expo)                         |
| Language     | TypeScript                                  |
| Navigation   | React Navigation                            |
| BLE          | react-native-ble-plx                        |

### Data Flow

```
Arduino (BLE) ←→ BLEService (singleton) ←→ Screens (React components)
                       ↓
              State listeners notify UI
              of connection changes and
              incoming sensor data
```

---
### BLE UUIDs

 UUIDs must match the Arduino firmware. Defined in existing Swift backend (`CBUUIDs.swift`) for compatibility.

| Service / Characteristic | UUID | Type |
|--------------------------|------|------|
| **Health Service** | `640dbb7a-d541-4af3-90fa-4faa92fba231` | Service |
| IMU RX | `fd4745de-c1cd-40e2-9bf9-7affb1fedb21` | Notify |
| sEMG RX | `3611f07f-13b2-413e-81bc-ab5c3bcd2737` | Notify |
| **OTA Service** | `6e400010-b5a3-f393-e0a9-e50e24dcca9e` | Service |
| OTA Write | `6e400011-b5a3-f393-e0a9-e50e24dcca9e` | Write |
| OTA Notify | `6e400012-b5a3-f393-e0a9-e50e24dcca9e` | Notify |

### Connection Flow

```
1. startScan()
   └── Scans for peripherals advertising the Health Service UUID

2. Device discovered → onDeviceDiscovered callback

3. connect(deviceId)
   ├── Stops scanning
   ├── Connects with 10-second timeout
   ├── Discovers all services and characteristics
   ├── Validates Health Service exists
   ├── Subscribes to IMU and sEMG notifications
   └── Monitors for disconnection events

4. Sensor data streams in via onSensorData callback
   └── Data buffer holds last 50 readings
```

### API

```typescript
// State
bleService.getState(): ConnectionState
bleService.getConnectedDevice(): DeviceInfo | null
bleService.getDataBuffer(): SensorData[]

// Listeners 
bleService.onStateChange(callback)
bleService.onDeviceDiscovered(callback)
bleService.onSensorData(callback)

// Actions
bleService.startScan()
bleService.stopScan()
bleService.connect(deviceId)
bleService.disconnect()
bleService.writeOTAChunk(data)
bleService.readMotorAngles()    // TODO: pending Arduino firmware
bleService.clearDataBuffer()
```

### Connection States

| State | Description |
|-------|-------------|
| `disconnected` | No device connected |
| `scanning` | Actively scanning for devices |
| `connecting` | Connection in progress |
| `connected` | Connected, not yet validated |
| `validating` | Discovering and validating services |
| `validated` | Fully connected and ready |
| `validationFailed` | Device missing required services |

---
### Bluetooth Permissions

**iOS** (`Info.plist` via app.json):
- `NSBluetoothAlwaysUsageDescription` - Helping Hands needs Bluetooth to connect to your prosthetic hand device.
- `NSBluetoothPeripheralUsageDescription` - Helping Hands needs Bluetooth to connect to your prosthetic hand device.

**Android** (`AndroidManifest.xml` via app.json):
- `BLUETOOTH_SCAN`
- `BLUETOOTH_CONNECT`
- `BLUETOOTH_ADVERTISE`
- `ACCESS_FINE_LOCATION`

---

### Running on Web vs. Mobile

The app can be previewed in a browser for rapid UI development, but BLE features are disabled on web. The `BLEService` detects the platform at initialization and logs a warning on web:

```
BLE not available on web — UI will work but no device connectivity
```

For full functionality, test on a physical iOS or Android device.

### Testing BLE Without Hardware

While waiting for the Arduino hardware, you can:
- Develop and test all UI on web or simulators
- The BLE service simulates a successful connection when no `bleManager` is available (connect resolves after 1 second)
- The Searching screen auto-advances after 3 seconds to simulate device discovery

### Existing Swift Backend Compatibility

This React Native frontend uses the **same BLE UUIDs** as the existing Swift iOS app in the repository root. Both implementations can communicate with the same Arduino hardware without changes. The UUID definitions in `BLEService.ts` are sourced directly from the Swift `CBUUIDs.swift` file.

### TODO / Future Work

- **Motor angle reading** — `BLEService.readMotorAngles()` is stubbed out, pending a characteristic definition in the Arduino firmware that exposes current motor positions
- **Gesture persistence** — Custom gestures are currently stored in component state; needs local storage (AsyncStorage or similar) and BLE write to persist to the device
- **Real sensor data display** — The Health Monitor screen uses static mock data; wire it to `bleService.onSensorData()` for live readings
- **OTA firmware updates** — The `writeOTAChunk()` method is implemented but the UI flow for selecting and uploading firmware files is not yet built
- **Games** — Placeholder screen for gesture/hand training games
- **State management** — As the app grows, consider a shared state solution (React Context or Zustand) to share gesture and connection state across screens
