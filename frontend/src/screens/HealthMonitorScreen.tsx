import React, { useEffect, useRef, useState } from 'react';
import {View, Text, StyleSheet, ScrollView, Animated, Easing} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';
import { bleService, ConnectionState } from '../services/BLEService';

// Map RSSI (dBm) to a 0-4 bar count and a friendly label.
function rssiToBars(rssi: number | null): { bars: number; label: string; color: string } {
  if (rssi == null) return { bars: 0, label: 'No Signal', color: colors.mediumGray };
  if (rssi >= -55) return { bars: 4, label: 'Excellent', color: colors.batteryGreen };
  if (rssi >= -65) return { bars: 3, label: 'Strong',    color: colors.batteryGreen };
  if (rssi >= -75) return { bars: 2, label: 'Okay',      color: colors.warning };
  if (rssi >= -85) return { bars: 1, label: 'Weak',      color: colors.warning };
  return { bars: 0, label: 'Very Weak', color: colors.wolfpackRed };
}

function formatUptime(ms: number): string {
  const s = Math.floor(ms / 1000);
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = s % 60;
  if (h > 0) return `${h}h ${m}m`;
  if (m > 0) return `${m}m ${sec}s`;
  return `${sec}s`;
}

export default function HealthMonitorScreen() {
  const [state, setState] = useState<ConnectionState>(bleService.getState());
  const [device, setDevice] = useState(bleService.getConnectedDevice());
  const [rssi, setRssi] = useState<number | null>(null);
  const [hasData, setHasData] = useState(false);
  const [packetCount, setPacketCount] = useState(0);
  const [packetsPerSec, setPacketsPerSec] = useState(0);
  const [uptime, setUptime] = useState(0);
  const pulse = useRef(new Animated.Value(1)).current;

  // Live counters 
  const packetCountRef = useRef(0);
  const lastTickRef = useRef({ count: 0, time: Date.now() });

  //  BLE state + sensor data
  useEffect(() => {
    let mounted = true;
    const unsubState = bleService.onStateChange((s) => {
      if (!mounted) return;
      setState(s);
      setDevice(bleService.getConnectedDevice());
      if (s === 'disconnected') {
        packetCountRef.current = 0;
        setPacketCount(0);
        setHasData(false);
      }
    });
    const unsubData = bleService.onSensorData(() => {
      if (!mounted) return;
      packetCountRef.current += 1;
      setPacketCount(packetCountRef.current);
      setHasData(true);
      Animated.sequence([
        Animated.timing(pulse, { toValue: 1.15, duration: 80,  useNativeDriver: true, easing: Easing.out(Easing.quad) }),
        Animated.timing(pulse, { toValue: 1,    duration: 200, useNativeDriver: true, easing: Easing.out(Easing.quad) }),
      ]).start();
    });

    return () => {
      mounted = false;
      unsubState();
      unsubData();
      pulse.stopAnimation();
    };
  }, [pulse]);

  // Poll RSSI every 2s while connected
  useEffect(() => {
    if (state !== 'validated') {
      setRssi(null);
      return;
    }
    let cancelled = false;
    const tick = async () => {
      const r = await bleService.readRSSI();
      if (!cancelled) setRssi(r);
    };
    tick();
    const id = setInterval(tick, 2000);
    return () => { cancelled = true; clearInterval(id); };
  }, [state]);

  // Heartbeat:  pkt/s and uptime once a second. Runs once for the screen's lifetime.
  useEffect(() => {
    const id = setInterval(() => {
      const now = Date.now();
      const dt = (now - lastTickRef.current.time) / 1000;
      const dCount = packetCountRef.current - lastTickRef.current.count;
      setPacketsPerSec(dt > 0 ? Math.round(dCount / dt) : 0);
      lastTickRef.current = { count: packetCountRef.current, time: now };
      const connectedAt = bleService.getConnectedAt();
      setUptime(connectedAt ? now - connectedAt : 0);
    }, 1000);
    return () => clearInterval(id);
  }, []);

  const isConnected = state === 'validated';
  const signal = rssiToBars(rssi);
  const activityWidth = packetsPerSec > 0 ? Math.min(100, packetsPerSec * 5) : hasData ? 8 : 0;

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Health Monitor</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Big friendly status card */}
        <View style={[styles.statusCard, { backgroundColor: isConnected ? '#E8F5E9' : '#FFEBEE' }]}>
          <Animated.View style={[styles.statusIcon, { transform: [{ scale: pulse }] }]}>
            <Ionicons
              name={isConnected ? 'hand-left' : 'alert-circle'}
              size={80}
              color={isConnected ? colors.batteryGreen : colors.wolfpackRed}
            />
          </Animated.View>
          <Text style={[styles.statusTitle, { color: isConnected ? colors.batteryGreen : colors.wolfpackRed }]}>
            {isConnected ? 'Your Hand is Working!' : 'Hand Not Connected'}
          </Text>
          <Text style={styles.statusSubtitle}>
            {isConnected
              ? hasData
                ? 'Sensors are sending data right now.'
                : 'Waiting for sensors to wake up...'
              : 'Go to Settings → Bluetooth to reconnect.'}
          </Text>
        </View>

        {/* Connected-for + Signal — the two things kids care about */}
        <View style={styles.row}>
          <View style={styles.tile}>
            <Ionicons name="time-outline" size={36} color={colors.wolfpackRed} />
            <Text style={styles.tileLabel}>Connected For</Text>
            <Text style={styles.tileValue}>{isConnected ? formatUptime(uptime) : '—'}</Text>
            <Text style={styles.tileHint}>Since you turned it on</Text>
          </View>

          <View style={styles.tile}>
            <View style={styles.barsRow}>
              {[0, 1, 2, 3].map((i) => (
                <View
                  key={i}
                  style={[
                    styles.bar,
                    { height: 8 + i * 6 },
                    { backgroundColor: i < signal.bars ? signal.color : colors.lightGray },
                  ]}
                />
              ))}
            </View>
            <Text style={styles.tileLabel}>Signal</Text>
            <Text style={[styles.tileValue, { color: signal.color }]}>{signal.label}</Text>
            <Text style={styles.tileHint}>{rssi != null ? `${rssi} dBm` : '—'}</Text>
          </View>
        </View>

        {/* Live activity bar — visual proof data is flowing */}
        <View style={styles.activityCard}>
          <Text style={styles.activityLabel}>Live Activity</Text>
          <View style={styles.activityBarBg}>
            <View style={[styles.activityBarFill, { width: `${activityWidth}%` }]} />
          </View>
          <Text style={styles.activityHint}>
            {packetsPerSec > 0
              ? `${packetsPerSec} updates/sec`
              : hasData
              ? 'Receiving data...'
              : 'Waiting for data...'}
          </Text>
        </View>

        {/* Developer details */}
        <Text style={styles.devHeader}>DEVELOPER DETAILS</Text>

        <View style={styles.devCard}>
          <DevRow label="State" value={state} />
          <DevRow label="Device ID" value={device?.id ?? '—'} mono />
          <DevRow label="Name" value={device?.name ?? '—'} />
          <DevRow label="RSSI" value={rssi != null ? `${rssi} dBm` : '—'} />
          <DevRow label="Total packets" value={String(packetCount)} />
          <DevRow label="Rate" value={`${packetsPerSec} pkt/s`} />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function DevRow({ label, value, mono }: { label: string; value: string; mono?: boolean }) {
  return (
    <View style={styles.devRow}>
      <Text style={styles.devRowLabel}>{label}</Text>
      <Text style={[styles.devRowValue, mono && styles.devMono]} numberOfLines={1}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.white },
  header: {
    backgroundColor: colors.wolfpackRed,
    paddingHorizontal: 20, paddingTop: 16, paddingBottom: 20,
    borderBottomLeftRadius: 20, borderBottomRightRadius: 20,
  },
  headerTitle: { fontSize: 28, fontWeight: '800', color: colors.white },
  scrollContent: { padding: 20, gap: 14, paddingBottom: 40 },

  statusCard: { borderRadius: 18, padding: 24, alignItems: 'center' },
  statusIcon: { marginBottom: 12 },
  statusTitle: { fontSize: 22, fontWeight: '800', marginBottom: 6, textAlign: 'center' },
  statusSubtitle: { fontSize: 14, color: colors.darkGray, textAlign: 'center' },

  row: { flexDirection: 'row', gap: 12 },
  tile: {
    flex: 1,
    backgroundColor: colors.backgroundGray,
    borderRadius: 14,
    padding: 16,
    alignItems: 'center',
    minHeight: 140,
    justifyContent: 'center',
  },
  tileLabel: { fontSize: 13, color: colors.mediumGray, marginTop: 8 },
  tileValue: { fontSize: 18, fontWeight: '800', color: colors.darkGray, marginTop: 2 },
  tileHint: { fontSize: 11, color: colors.mediumGray, marginTop: 2 },

  barsRow: { flexDirection: 'row', alignItems: 'flex-end', gap: 4, height: 32 },
  bar: { width: 6, borderRadius: 2 },

  activityCard: { backgroundColor: colors.backgroundGray, borderRadius: 14, padding: 16 },
  activityLabel: { fontSize: 13, color: colors.mediumGray, marginBottom: 8 },
  activityBarBg: { height: 14, borderRadius: 7, backgroundColor: colors.lightGray, overflow: 'hidden' },
  activityBarFill: { height: '100%', backgroundColor: colors.wolfpackRed, borderRadius: 7 },
  activityHint: { fontSize: 12, color: colors.mediumGray, marginTop: 6, textAlign: 'right' },

  devHeader: {
    fontSize: 12, fontWeight: '700', color: colors.mediumGray,
    marginTop: 10, marginBottom: -4, letterSpacing: 1,
  },
  devCard: {
    backgroundColor: '#FAFAFA',
    borderRadius: 12,
    padding: 14,
    borderWidth: 1,
    borderColor: colors.lightGray,
  },
  devRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 4 },
  devRowLabel: { fontSize: 12, color: colors.mediumGray },
  devRowValue: { fontSize: 12, color: colors.darkGray, fontWeight: '600', maxWidth: '60%' },
  devMono: { fontFamily: 'Courier', fontSize: 11, color: colors.darkGray },
});
