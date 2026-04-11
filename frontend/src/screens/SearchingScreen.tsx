import React, { useEffect, useState, useRef } from 'react';
import {View, Text, StyleSheet, ActivityIndicator, TouchableOpacity, ScrollView} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';
import { bleService, DeviceInfo, ConnectionState } from '../services/BLEService';

export default function SearchingScreen({ navigation }: any) {
  const [status, setStatus] = useState<ConnectionState>('scanning');
  const [discovered, setDiscovered] = useState<DeviceInfo[]>([]);
  const [error, setError] = useState<string | null>(null);
  const hasConnected = useRef(false);

  useEffect(() => {
    // Subscribe to BLE state changes
    const unsubState = bleService.onStateChange((newState) => {
      console.log('[BLE] State changed:', newState);
      setStatus(newState);

      if (newState === 'validated') {
        // Successfully connected and validated — move on
        navigation.replace('Connected');
      } else if (newState === 'validationFailed') {
        setError('Device found but is missing required services.');
      }
    });

    // Subscribe to device discovery
    const unsubDevice = bleService.onDeviceDiscovered((device) => {
      console.log('[BLE] Discovered device:', device.name, device.id, 'RSSI:', device.rssi);
      setDiscovered((prev) => {
        // Avoid duplicates
        if (prev.some((d) => d.id === device.id)) return prev;
        return [...prev, device];
      });

      // Auto-connect to the first hand device we find.
      if (!hasConnected.current) {
        hasConnected.current = true;
        bleService.connect(device.id).catch((err) => {
          setError(`Connection failed: ${err.message || err}`);
        });
      }
    });

    // Start the scan
    console.log('[BLE] Starting scan...');
    bleService.startScan().catch((err) => {
      console.error('[BLE] Scan error:', err);
      setError(`Scan failed: ${err.message || err}`);
    });

    // Timeout — if nothing found in 20 seconds, show error
    const timeout = setTimeout(() => {
      if (!hasConnected.current) {
        setError('No hand device found nearby. Make sure it is powered on and in range.');
        bleService.stopScan();
      }
    }, 20000);

    return () => {
      unsubState();
      unsubDevice();
      clearTimeout(timeout);
      bleService.stopScan();
    };
  }, [navigation]);

  const handleRetry = () => {
    setError(null);
    setDiscovered([]);
    hasConnected.current = false;
    bleService.startScan().catch((err) => {
      setError(`Scan failed: ${err.message || err}`);
    });
  };

  const handleCancel = () => {
    bleService.stopScan();
    navigation.goBack();
  };

  const getStatusText = () => {
    switch (status) {
      case 'scanning': return 'Looking for your hand';
      case 'connecting': return 'Connecting to device...';
      case 'validating': return 'Validating device services...';
      case 'validated': return 'Connected!';
      default: return 'Searching...';
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.iconCircle}>
          <Ionicons name="bluetooth" size={60} color={colors.wolfpackRed} />
        </View>

        <Text style={styles.title}>
          {error ? 'Oops!' : 'Searching...'}
        </Text>
        <Text style={styles.subtitle}>
          {error || getStatusText()}
        </Text>

        {!error && (
          <ActivityIndicator size="large" color={colors.wolfpackRed} style={styles.spinner} />
        )}

        {/* Debug: show discovered devices */}
        {discovered.length > 0 && (
          <View style={styles.debugBox}>
            <Text style={styles.debugTitle}>Devices Found:</Text>
            {discovered.map((d) => (
              <Text key={d.id} style={styles.debugText}>
                {d.name} ({d.rssi} dBm)
              </Text>
            ))}
          </View>
        )}

        {error ? (
          <View style={styles.buttonRow}>
            <TouchableOpacity style={styles.cancelButton} onPress={handleCancel}>
              <Text style={styles.cancelButtonText}>Go Back</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.retryButton} onPress={handleRetry}>
              <Text style={styles.retryButtonText}>Retry</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <TouchableOpacity style={styles.connectingButton} onPress={handleCancel}>
            <Text style={styles.connectingText}>Cancel</Text>
          </TouchableOpacity>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.white,
  },
  content: {
    flexGrow: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 40,
    paddingVertical: 40,
  },
  iconCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: '#F0E6FF',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
  },
  title: {
    fontSize: 24,
    fontWeight: '800',
    color: colors.wolfpackRed,
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: colors.mediumGray,
    marginBottom: 20,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  spinner: {
    marginBottom: 30,
  },
  debugBox: {
    backgroundColor: colors.backgroundGray,
    padding: 12,
    borderRadius: 10,
    marginBottom: 20,
    width: '100%',
  },
  debugTitle: {
    fontSize: 12,
    fontWeight: '700',
    color: colors.darkGray,
    marginBottom: 4,
  },
  debugText: {
    fontSize: 12,
    color: colors.mediumGray,
    fontFamily: 'Courier',
  },
  connectingButton: {
    backgroundColor: colors.reynoldsRed,
    paddingHorizontal: 40,
    paddingVertical: 14,
    borderRadius: 25,
  },
  connectingText: {
    color: colors.white,
    fontSize: 16,
    fontWeight: '700',
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
  },
  cancelButton: {
    backgroundColor: colors.lightGray,
    paddingHorizontal: 30,
    paddingVertical: 14,
    borderRadius: 25,
  },
  cancelButtonText: {
    color: colors.darkGray,
    fontSize: 16,
    fontWeight: '700',
  },
  retryButton: {
    backgroundColor: colors.wolfpackRed,
    paddingHorizontal: 30,
    paddingVertical: 14,
    borderRadius: 25,
  },
  retryButtonText: {
    color: colors.white,
    fontSize: 16,
    fontWeight: '700',
  },
});
