import { Platform } from 'react-native';

// UUIDs — must match Arduino firmware and Swift CBUUIDs.swift
export const BLE_UUIDS = {
  // Health Service: streams IMU + sEMG sensor data
  healthService: '640dbb7a-d541-4af3-90fa-4faa92fba231',
  imuRX: 'fd4745de-c1cd-40e2-9bf9-7affb1fedb21',       // notify
  semgRX: '3611f07f-13b2-413e-81bc-ab5c3bcd2737',       // notify

  // OTA Service: firmware updates over BLE
  otaService: '6e400010-b5a3-f393-e0a9-e50e24dcca9e',
  otaWrite: '6e400011-b5a3-f393-e0a9-e50e24dcca9e',     // write
  otaNotify: '6e400012-b5a3-f393-e0a9-e50e24dcca9e',    // notify
};

export type ConnectionState =
  | 'disconnected'
  | 'scanning'
  | 'connecting'
  | 'connected'
  | 'validating'
  | 'validated'
  | 'validationFailed';

export type DeviceInfo = {
  id: string;
  name: string;
  battery: number;
  rssi: number;
  connectionState: ConnectionState;
};

export type SensorData = {
  timestamp: number;
  imu: number[] | null;
  semg: number[] | null;
};

type StateListener = (state: ConnectionState) => void;
type DeviceListener = (device: DeviceInfo) => void;
type DataListener = (data: SensorData) => void;

/**
 * BLE connection flow (mirrors Swift BluetoothManager):
 *
 * 1. startScan() — scans for peripherals advertising healthService UUID
 * 2. Device found - onDeviceDiscovered callback fires
 * 3. connect(deviceId) — connects to the peripheral
 * 4. Auto-discovers services - validates healthService + otaService exist
 * 5. Subscribes to IMU and sEMG notify characteristics
 * 6. Data streams in via onSensorData callback
 *
 * For OTA updates:
 * 1. Write firmware chunks to otaWrite characteristic
 * 2. Monitor otaNotify for progress/status
 */
class BLEService {
  private state: ConnectionState = 'disconnected';
  private connectedDevice: DeviceInfo | null = null;
  private stateListeners = new Set<StateListener>();
  private deviceListeners = new Set<DeviceListener>();
  private dataListeners = new Set<DataListener>();
  private dataBuffer: SensorData[] = [];
  private bleManager: any = null; // BleManager from react-native-ble-plx

  constructor() {
    this.initBLE();
  }

  private async initBLE() {
    // Only initialize on native platforms (not web)
    if (Platform.OS === 'web') {
      console.log('BLE not available on web — UI will work but no device connectivity');
      return;
    }

    try {
      // Dynamic import so web builds don't crash
      const { BleManager } = require('react-native-ble-plx');
      this.bleManager = new BleManager();
    } catch {
      console.log('react-native-ble-plx not available — running in UI-only mode');
    }
  }

  //  State Management 

  getState(): ConnectionState {
    return this.state;
  }

  getConnectedDevice(): DeviceInfo | null {
    return this.connectedDevice;
  }

  getDataBuffer(): SensorData[] {
    return this.dataBuffer;
  }

  onStateChange(listener: StateListener) {
    this.stateListeners.add(listener);
    return () => { this.stateListeners.delete(listener); };
  }

  onDeviceDiscovered(listener: DeviceListener) {
    this.deviceListeners.add(listener);
    return () => { this.deviceListeners.delete(listener); };
  }

  onSensorData(listener: DataListener) {
    this.dataListeners.add(listener);
    return () => { this.dataListeners.delete(listener); };
  }

  private setState(newState: ConnectionState) {
    this.state = newState;
    this.stateListeners.forEach((l) => l(newState));
  }

  // Scanning 

  async startScan(): Promise<void> {
    this.setState('scanning');

    if (!this.bleManager) return;

    this.bleManager.startDeviceScan(
      [BLE_UUIDS.healthService], 
      { allowDuplicates: false },
      (error: any, device: any) => {
        if (error) {
          console.error('Scan error:', error);
          this.setState('disconnected');
          return;
        }
        if (device?.name) {
          const info: DeviceInfo = {
            id: device.id,
            name: device.name || 'Unknown Hand',
            battery: -1, 
            rssi: device.rssi ?? -100,
            connectionState: 'disconnected',
          };
          this.deviceListeners.forEach((l) => l(info));
        }
      }
    );
  }

  async stopScan(): Promise<void> {
    if (this.bleManager) {
      this.bleManager.stopDeviceScan();
    }
    if (this.state === 'scanning') {
      this.setState('disconnected');
    }
  }

  // Connection 

  async connect(deviceId: string): Promise<void> {
    if (!this.bleManager) {
      // Simulate connection for UI testing
      this.setState('connecting');
      setTimeout(() => this.setState('validated'), 1000);
      return;
    }

    try {
      this.setState('connecting');
      this.bleManager.stopDeviceScan();

      const device = await this.bleManager.connectToDevice(deviceId, {
        timeout: 10000, // 10s timeout like Swift backend
      });

      this.setState('validating');

      await device.discoverAllServicesAndCharacteristics();

      // Validate required services exist
      const services = await device.services();
      const serviceIds = services.map((s: any) => s.uuid.toLowerCase());

      const hasHealth = serviceIds.includes(BLE_UUIDS.healthService);
      const hasOTA = serviceIds.includes(BLE_UUIDS.otaService);

      if (!hasHealth) {
        console.error('Device missing health service');
        this.setState('validationFailed');
        await this.bleManager.cancelDeviceConnection(deviceId);
        return;
      }

      // Subscribe to sensor data notifications
      await this.subscribeToSensorData(device);

      this.connectedDevice = {
        id: device.id,
        name: device.name || 'Helping Hand',
        battery: -1,
        rssi: -1,
        connectionState: 'validated',
      };

      this.setState('validated');

      // Monitor disconnection
      this.bleManager.onDeviceDisconnected(deviceId, () => {
        this.connectedDevice = null;
        this.setState('disconnected');
      });
    } catch (error) {
      console.error('Connection failed:', error);
      this.setState('validationFailed');
    }
  }

  private async subscribeToSensorData(device: any): Promise<void> {
    // Subscribe to IMU data
    device.monitorCharacteristicForService(
      BLE_UUIDS.healthService,
      BLE_UUIDS.imuRX,
      (error: any, characteristic: any) => {
        if (error) return;
        if (characteristic?.value) {
          const data = this.parseCharacteristicValue(characteristic.value);
          const sensorData: SensorData = {
            timestamp: Date.now(),
            imu: data,
            semg: null,
          };
          this.pushData(sensorData);
        }
      }
    );

    // Subscribe to sEMG data
    device.monitorCharacteristicForService(
      BLE_UUIDS.healthService,
      BLE_UUIDS.semgRX,
      (error: any, characteristic: any) => {
        if (error) return;
        if (characteristic?.value) {
          const data = this.parseCharacteristicValue(characteristic.value);
          const sensorData: SensorData = {
            timestamp: Date.now(),
            imu: null,
            semg: data,
          };
          this.pushData(sensorData);
        }
      }
    );
  }

  private parseCharacteristicValue(base64Value: string): number[] {
    // BLE data comes as base64 
    const raw = atob(base64Value);
    return Array.from(raw).map((c) => c.charCodeAt(0));
  }

  private pushData(data: SensorData) {
    this.dataBuffer.push(data);
    if (this.dataBuffer.length > 50) {
      this.dataBuffer.shift(); // Keep last 50 like Swift backend
    }
    this.dataListeners.forEach((l) => l(data));
  }

  // OTA Firmware Updates 

  async writeOTAChunk(data: Uint8Array): Promise<void> {
    if (!this.bleManager || !this.connectedDevice) return;

    const base64 = btoa(String.fromCharCode(...data));
    const device = await this.bleManager.connectedDevices([BLE_UUIDS.otaService]);
    if (device.length > 0) {
      await device[0].writeCharacteristicWithResponseForService(
        BLE_UUIDS.otaService,
        BLE_UUIDS.otaWrite,
        base64
      );
    }
  }

  // Motor Angle Reading (for custom gestures) 

  async readMotorAngles(): Promise<number[] | null> {
    // TODO: When Arduino firmware exposes motor angle characteristic read it here. 
    if (!this.bleManager || !this.connectedDevice) {
      return null;
    }
    // Placeholder: will be implemented when motor angle characteristic is defined
    return null;
  }

  // Disconnect 

  async disconnect(): Promise<void> {
    if (this.bleManager && this.connectedDevice) {
      try {
        await this.bleManager.cancelDeviceConnection(this.connectedDevice.id);
      } catch {
        // Already disconnected
      }
    }
    this.connectedDevice = null;
    this.dataBuffer = [];
    this.setState('disconnected');
  }

  clearDataBuffer() {
    this.dataBuffer = [];
  }
}

export const bleService = new BLEService();
