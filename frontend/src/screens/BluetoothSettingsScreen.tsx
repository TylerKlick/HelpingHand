import React, { useEffect, useState } from 'react';
import {View, Text, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator, Alert} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';
import { bleService, ConnectionState, DeviceInfo } from '../services/BLEService';

//let user check BLE connection 
export default function BluetoothSettingsScreen({ navigation }: any) {
  const [state, setState] = useState<ConnectionState>(bleService.getState());
  const [device, setDevice] = useState<DeviceInfo | null>(bleService.getConnectedDevice());
  const [discovered, setDiscovered] = useState<DeviceInfo[]>([]);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    const unsubState = bleService.onStateChange((s) => {
      setState(s);
      setDevice(bleService.getConnectedDevice());
      if (s === 'validated') {
        setBusy(false);
        setDiscovered([]);
      }
      if (s === 'disconnected' || s === 'validationFailed') {
        setBusy(false);
      }
    });
    const unsubDevice = bleService.onDeviceDiscovered((d) => {
      setDiscovered((prev) => (prev.some((p) => p.id === d.id) ? prev : [...prev, d]));
    });
    return () => { unsubState(); unsubDevice(); };
  }, []);

  const isConnected = state === 'validated';
  const isScanning = state === 'scanning';
  const isConnecting = state === 'connecting' || state === 'validating';

  const handleScan = async () => {
    setBusy(true);
    setDiscovered([]);
    try {
      await bleService.startScan();
      // Auto-stop after 15s 
      setTimeout(() => {
        if (bleService.getState() === 'scanning') {
          bleService.stopScan();
          setBusy(false);
        }
      }, 15000);
    } catch (e: any) {
      setBusy(false);
      Alert.alert('Scan failed', e?.message ?? String(e));
    }
  };

  const handleConnect = async (id: string) => {
    setBusy(true);
    try {
      await bleService.connect(id);
    } catch (e: any) {
      setBusy(false);
      Alert.alert('Connection failed', e?.message ?? String(e));
    }
  };

  const handleDisconnect = () => {
    Alert.alert(
      'Disconnect Hand?',
      'Your hand will stop moving until you reconnect.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Disconnect',
          style: 'destructive',
          onPress: async () => {
            await bleService.disconnect();
          },
        },
      ]
    );
  };

  const statusText = isConnected ? 'Connected' : isConnecting ? 'Connecting...' : isScanning ? 'Searching...' : 'Not Connected';
  const statusColor = isConnected ? colors.batteryGreen : isConnecting || isScanning ? colors.warning : colors.wolfpackRed;

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Ionicons name="chevron-back" size={26} color={colors.white} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Bluetooth</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        {/* Status card */}
        <View style={styles.statusCard}>
          <View style={[styles.statusDot, { backgroundColor: statusColor }]} />
          <View style={{ flex: 1 }}>
            <Text style={styles.statusLabel}>Status</Text>
            <Text style={[styles.statusValue, { color: statusColor }]}>{statusText}</Text>
          </View>
          {(busy || isScanning || isConnecting) && (
            <ActivityIndicator size="small" color={colors.wolfpackRed} />
          )}
        </View>

        {/* Connected device info */}
        {isConnected && device && (
          <View style={styles.card}>
            <Text style={styles.cardTitle}>Current Device</Text>
            <Row label="Name" value={device.name} />
            <Row label="ID" value={device.id} mono />
            <Row label="Signal" value={device.rssi !== -1 ? `${device.rssi} dBm` : '—'} />
            <TouchableOpacity style={styles.disconnectBtn} onPress={handleDisconnect}>
              <Ionicons name="close-circle-outline" size={18} color={colors.white} />
              <Text style={styles.disconnectText}>Disconnect</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Scan / discovered devices */}
        {!isConnected && (
          <View style={styles.card}>
            <Text style={styles.cardTitle}>Available Devices</Text>
            {discovered.length === 0 && !isScanning && (
              <Text style={styles.empty}>
                Tap "Scan" to look for your hand. Make sure it is powered on and nearby.
              </Text>
            )}
            {isScanning && discovered.length === 0 && (
              <Text style={styles.empty}>Searching...</Text>
            )}
            {discovered.map((d) => (
              <TouchableOpacity
                key={d.id}
                style={styles.deviceRow}
                onPress={() => handleConnect(d.id)}
                disabled={isConnecting}
              >
                <Ionicons name="hand-left" size={22} color={colors.wolfpackRed} />
                <View style={{ flex: 1 }}>
                  <Text style={styles.deviceName}>{d.name}</Text>
                  <Text style={styles.deviceMeta}>{d.rssi} dBm</Text>
                </View>
                <Ionicons name="chevron-forward" size={18} color={colors.mediumGray} />
              </TouchableOpacity>
            ))}

            <TouchableOpacity
              style={[styles.scanBtn, isScanning && styles.scanBtnDisabled]}
              onPress={handleScan}
              disabled={isScanning || isConnecting}
            >
              <Ionicons name="bluetooth" size={18} color={colors.white} />
              <Text style={styles.scanText}>{isScanning ? 'Scanning...' : 'Scan for Hand'}</Text>
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

function Row({ label, value, mono }: { label: string; value: string; mono?: boolean }) {
  return (
    <View style={styles.row}>
      <Text style={styles.rowLabel}>{label}</Text>
      <Text style={[styles.rowValue, mono && styles.mono]} numberOfLines={1}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.white },
  header: {
    backgroundColor: colors.wolfpackRed,
    paddingHorizontal: 20, paddingTop: 16, paddingBottom: 20,
    borderBottomLeftRadius: 20, borderBottomRightRadius: 20,
    flexDirection: 'row', alignItems: 'center', gap: 6,
  },
  backBtn: { padding: 4 },
  headerTitle: { fontSize: 26, fontWeight: '800', color: colors.white },
  content: { padding: 20, gap: 14, paddingBottom: 40 },

  statusCard: {
    flexDirection: 'row', alignItems: 'center', gap: 14,
    backgroundColor: colors.backgroundGray, borderRadius: 14, padding: 18,
  },
  statusDot: { width: 14, height: 14, borderRadius: 7 },
  statusLabel: { fontSize: 12, color: colors.mediumGray, textTransform: 'uppercase', letterSpacing: 1 },
  statusValue: { fontSize: 18, fontWeight: '800', marginTop: 2 },

  card: {
    backgroundColor: colors.backgroundGray, borderRadius: 14, padding: 18, gap: 10,
  },
  cardTitle: {
    fontSize: 12, fontWeight: '700', color: colors.mediumGray,
    textTransform: 'uppercase', letterSpacing: 1,
  },

  row: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 4 },
  rowLabel: { fontSize: 13, color: colors.mediumGray },
  rowValue: { fontSize: 13, color: colors.darkGray, fontWeight: '600', maxWidth: '65%' },
  mono: { fontFamily: 'Courier', fontSize: 11 },

  empty: { fontSize: 13, color: colors.mediumGray, fontStyle: 'italic', paddingVertical: 6 },

  deviceRow: {
    flexDirection: 'row', alignItems: 'center', gap: 12,
    paddingVertical: 12, borderTopWidth: 1, borderTopColor: colors.lightGray,
  },
  deviceName: { fontSize: 15, fontWeight: '600', color: colors.darkGray },
  deviceMeta: { fontSize: 11, color: colors.mediumGray, marginTop: 2 },

  scanBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    backgroundColor: colors.wolfpackRed, paddingVertical: 14, borderRadius: 25, marginTop: 6,
  },
  scanBtnDisabled: { opacity: 0.6 },
  scanText: { color: colors.white, fontSize: 16, fontWeight: '700' },

  disconnectBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    backgroundColor: colors.reynoldsRed, paddingVertical: 12, borderRadius: 22, marginTop: 6,
  },
  disconnectText: { color: colors.white, fontSize: 15, fontWeight: '700' },

  helpText: {
    fontSize: 12, color: colors.mediumGray, textAlign: 'center', paddingHorizontal: 12, marginTop: 4,
  },
});
