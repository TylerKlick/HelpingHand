import { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import AppNavigator from './src/navigation/AppNavigator';
import { notificationService } from './src/services/NotificationService';
import { bleService } from './src/services/BLEService';

export default function App() {
  useEffect(() => {
    notificationService.init();

    // Fire notification if hand disconnects while app is in background
    const unsub = bleService.onStateChange((state) => {
      if (state === 'disconnected') {
        const device = bleService.getConnectedDevice();
        notificationService.notifyConnectionLost(device?.name ?? 'Your hand');
      }
    });
    return () => unsub();
  }, []);

  return (
    <SafeAreaProvider>
      <StatusBar style="dark" />
      <AppNavigator />
    </SafeAreaProvider>
  );
}
