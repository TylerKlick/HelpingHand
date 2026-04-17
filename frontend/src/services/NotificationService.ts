import { Platform } from 'react-native';
import * as Notifications from 'expo-notifications';
import AsyncStorage from '@react-native-async-storage/async-storage';

export type NotificationType =
  | 'connection_lost'
  | 'battery_low'
  | 'firmware_update'
  | 'health_alert'
  | 'errors';

export const NOTIFICATION_TYPES: {
  key: NotificationType;
  label: string;
  desc: string;
  defaultOn: boolean;
}[] = [
  {
    key: 'connection_lost',
    label: 'Hand Disconnected',
    desc: 'Alert when your hand loses its Bluetooth connection',
    defaultOn: true,
  },
  {
    key: 'battery_low',
    label: 'Low Battery',
    desc: 'Alert when the battery drops below 20%',
    defaultOn: true,
  },
  {
    key: 'firmware_update',
    label: 'Firmware Updates',
    desc: 'Alert when a new update is available for your hand',
    defaultOn: true,
  },
  {
    key: 'health_alert',
    label: 'Health Alerts',
    desc: 'Alert when sensor readings fall outside the normal range',
    defaultOn: false,
  },
  {
    key: 'errors',
    label: 'Errors',
    desc: 'Alert when the app encounters a problem',
    defaultOn: false,
  },
];

const PREFS_KEY = '@notifications_prefs';
const PERMISSION_KEY = '@notifications_permission_asked';

function defaultPrefs(): Record<NotificationType, boolean> {
  const prefs: Record<string, boolean> = {};
  for (const t of NOTIFICATION_TYPES) prefs[t.key] = t.defaultOn;
  return prefs as Record<NotificationType, boolean>;
}

//appearance 
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: false,
    shouldSetBadge: false,
    shouldShowBanner: true,
    shouldShowList: true,
  }),
});

class NotificationService {
  private permissionGranted = false;
  private prefs: Record<NotificationType, boolean> = defaultPrefs();
  private ready = false;


  // check permissions, don't prompt yet 
  async init(): Promise<void> {
    if (Platform.OS === 'web') return;
    await this.loadPrefs();
    const { status } = await Notifications.getPermissionsAsync();
    this.permissionGranted = status === 'granted';
    this.ready = true;
  }

  async getPermissionStatus(): Promise<'granted' | 'denied' | 'undetermined'> {
    if (Platform.OS === 'web') return 'denied';
    const { status } = await Notifications.getPermissionsAsync();
    return status as 'granted' | 'denied' | 'undetermined';
  }

  //prompt now
  async requestPermission(): Promise<boolean> {
    if (Platform.OS === 'web') return false;
    const { status } = await Notifications.requestPermissionsAsync({
      ios: {
        allowAlert: true,
        allowBadge: false,
        allowSound: false,
      },
    });
    this.permissionGranted = status === 'granted';
    await AsyncStorage.setItem(PERMISSION_KEY, 'asked');
    return this.permissionGranted;
  }

  isPermissionGranted(): boolean {
    return this.permissionGranted;
  }

  private async loadPrefs(): Promise<void> {
    try {
      const raw = await AsyncStorage.getItem(PREFS_KEY);
      if (raw) {
        const saved = JSON.parse(raw);
        // Merge saved prefs w/ defaults 
        this.prefs = { ...defaultPrefs(), ...saved };
      }
    } catch {
      // Use defaults
    }
  }

  async savePrefs(): Promise<void> {
    try {
      await AsyncStorage.setItem(PREFS_KEY, JSON.stringify(this.prefs));
    } catch {}
  }

  getPrefs(): Record<NotificationType, boolean> {
    return { ...this.prefs };
  }

  async setPref(type: NotificationType, enabled: boolean): Promise<void> {
    this.prefs[type] = enabled;
    await this.savePrefs();
  }

  isEnabled(type: NotificationType): boolean {
    return this.permissionGranted && this.prefs[type];
  }

  //SEND
  private async send(
    type: NotificationType,
    title: string,
    body: string,
  ): Promise<void> {
    if (!this.isEnabled(type)) return;
    try {
      await Notifications.scheduleNotificationAsync({
        content: { title, body },
        trigger: null, // immediate
      });
    } catch (e) {
      console.warn('[Notifications] Failed to send:', e);
    }
  }

  // Call from BLEService, Health Monitor, Updates screen
  async notifyConnectionLost(deviceName = 'Your hand'): Promise<void> {
    await this.send(
      'connection_lost',
      '✋ Hand Disconnected',
      `${deviceName} lost its Bluetooth connection. Open the app to reconnect.`,
    );
  }

  async notifyBatteryLow(percent: number): Promise<void> {
    await this.send(
      'battery_low',
      '🔋 Low Battery',
      `Your hand's battery is at ${percent}%. Charge it soon!`,
    );
  }

  async notifyFirmwareUpdate(version: string): Promise<void> {
    await this.send(
      'firmware_update',
      '⬆️ Update Available',
      `Firmware version ${version} is ready to install. Tap to update.`,
    );
  }

  async notifyHealthAlert(message: string): Promise<void> {
    await this.send('health_alert', '⚠️ Health Alert', message);
  }

  async notifyError(message: string): Promise<void> {
    await this.send('errors', '❗ Something went wrong :(', message);
  }
}

export const notificationService = new NotificationService();
