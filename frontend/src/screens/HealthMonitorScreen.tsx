import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

const metrics = [
  { icon: 'battery-full' as const, label: 'Battery', value: '85%', color: colors.batteryGreen },
  { icon: 'thermometer-outline' as const, label: 'Temperature', value: '36°C', color: colors.info },
  { icon: 'pulse-outline' as const, label: 'Motor Status', value: 'All OK', color: colors.batteryGreen },
  { icon: 'wifi-outline' as const, label: 'Signal Strength', value: 'Strong', color: colors.batteryGreen },
  { icon: 'time-outline' as const, label: 'Uptime', value: '2h 34m', color: colors.mediumGray },
];

export default function HealthMonitorScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Health Monitor</Text>
      </View>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {metrics.map((m) => (
          <View key={m.label} style={styles.card}>
            <Ionicons name={m.icon} size={30} color={m.color} />
            <View style={styles.cardText}>
              <Text style={styles.cardLabel}>{m.label}</Text>
              <Text style={[styles.cardValue, { color: m.color }]}>{m.value}</Text>
            </View>
          </View>
        ))}
      </ScrollView>
    </SafeAreaView>
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
  scrollContent: { padding: 20, gap: 12 },
  card: {
    flexDirection: 'row', alignItems: 'center', gap: 16,
    backgroundColor: colors.backgroundGray, borderRadius: 14, padding: 20,
  },
  cardText: { flex: 1 },
  cardLabel: { fontSize: 14, color: colors.mediumGray },
  cardValue: { fontSize: 22, fontWeight: '700', marginTop: 2 },
});
