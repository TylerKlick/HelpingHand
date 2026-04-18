# Helping Hands - Frontend
---

## Getting Started

### Prerequisites

| Tool | Notes |
|------|-------|
| Node.js v20+ | [nodejs.org](https://nodejs.org) |
| Expo CLI | `npm install -g expo-cli` |
| Xcode (iOS) | Required for building to iPhone |
| Android Studio (Android) | Required for building to Android |
| Physical device | **Required** for BLE — emulators have no Bluetooth |

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
npx expo run:ios --device

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
├── android/
│   └── local.properties             # Android SDK path (gitignored)
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
    │   ├── BluetoothSettingsScreen.tsx   # Scan / connect / disconnect 
    │   ├── NotificationSettingsScreen.tsx    # Per-type notification toggles + permissions
    │   ├── DataPrivacyScreen.tsx     # Accurate data & privacy disclosure
    │   ├── HelpScreen.tsx           # Help topics
    │   ├── UpdatesScreen.tsx         # Firmware update status
    │   └── GamesScreen.tsx           # Placeholder for training games
    ├── services/
    │   ├── BLEService.ts             # Bluetooth Low Energy manager
    │   └── NotificationService.ts    # Notification permissions + per-type preferences
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
| Notifications | expo-notifications |

### Data Flow

```
Arduino (BLE) ←→ BLEService (singleton) ←→ Screens (React components)
                       ↓
              State listeners notify UI
              of connection changes and
              incoming sensor data
```

---

## BLE Service (`BLEService.ts`)

Singleton that wraps `react-native-ble-plx`. All screens talk to it through
a listener pattern — no prop drilling.

### UUIDs

Must match the Arduino firmware. Sourced from the Swift backend's `CBUUIDs.swift`.

| Service / Characteristic | UUID | Direction |
|--------------------------|------|-----------|
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

connect(deviceId)
  ├─ Stops scan
  ├─ Connects with 10s timeout
  ├─ discoverAllServicesAndCharacteristics()
  ├─ Validates Health Service UUID present
  ├─ Subscribes to IMU + sEMG notify characteristics
  └─ Monitors disconnection → fires notifyConnectionLost()
```
3. connect(deviceId)
   ├── Stops scanning
   ├── Connects with 10-second timeout
   ├── Discovers all services and characteristics
   ├── Validates Health Service exists
   ├── Subscribes to IMU and sEMG notifications
   └── Monitors for disconnection events

### Connection States

| State | Description |
|-------|-------------|
| `disconnected` | No device |
| `scanning` | Actively scanning |
| `connecting` | TCP handshake in progress |
| `validating` | Discovering services |
| `validated` | Fully connected and streaming |
| `validationFailed` | Connected but missing required services |

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
bleService.writeOTAChunk(data: Uint8Array) // firmware update chunk
bleService.readMotorAngles()  // TODO: pending Arduino firmware
bleService.readRSSI(): Promise<number | null>   // live signal strength
bleService.clearDataBuffer()
```

---

### Notification Types

| Type | Default | Trigger |
|------|---------|---------|
| `connection_lost` | **On** | BLE disconnects |
| `battery_low` | **On** | Battery < 20% (pending firmware) |
| `firmware_update` | **On** | New firmware detected |
| `health_alert` | Off | Sensor reading out of range (pending) |
| `errors` | Off | App-level errors |

---


### iOS (`app.json` → `Info.plist`)

| Key | Reason |
|-----|--------|
| `NSBluetoothAlwaysUsageDescription` | Connect to prosthetic hand |
| `NSBluetoothPeripheralUsageDescription` | Connect to prosthetic hand |
| `NSUserNotificationsUsageDescription` | Alerts for disconnect, battery, updates |

### Android (`app.json` → `AndroidManifest.xml`)

| Permission | Reason |
|------------|--------|
| `BLUETOOTH_SCAN` | Scan for hand |
| `BLUETOOTH_CONNECT` | Connect to hand |
| `ACCESS_FINE_LOCATION` | Required by Android for BLE scanning |
| `POST_NOTIFICATIONS` | Android notification permission |
| `RECEIVE_BOOT_COMPLETED` | Reschedule notifications after reboot |
| `VIBRATE` | Notification vibration |
