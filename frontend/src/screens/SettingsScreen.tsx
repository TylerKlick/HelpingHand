import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

const settingsItems = [
  { icon: 'bluetooth-outline' as const, label: 'Bluetooth', detail: 'Connected' },
  { icon: 'notifications-outline' as const, label: 'Notifications', detail: 'On' },
  { icon: 'hand-left-outline' as const, label: 'Hand Preferences', detail: 'Left Hand' },
  { icon: 'analytics-outline' as const, label: 'Data & Privacy', detail: '' },
  { icon: 'information-circle-outline' as const, label: 'About', detail: 'v1.0.0' },
];

export default function SettingsScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Settings</Text>
      </View>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {settingsItems.map((item) => (
          <TouchableOpacity key={item.label} style={styles.row}>
            <View style={styles.rowLeft}>
              <Ionicons name={item.icon} size={22} color={colors.wolfpackRed} />
              <Text style={styles.rowLabel}>{item.label}</Text>
            </View>
            <View style={styles.rowRight}>
              <Text style={styles.rowDetail}>{item.detail}</Text>
              <Ionicons name="chevron-forward" size={18} color={colors.mediumGray} />
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.white },
  header: {
    backgroundColor: colors.wolfpackRed,
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 20,
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 20,
  },
  headerTitle: { fontSize: 28, fontWeight: '800', color: colors.white },
  scrollContent: { padding: 20, gap: 2 },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: colors.lightGray,
  },
  rowLeft: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  rowLabel: { fontSize: 16, fontWeight: '500', color: colors.black },
  rowRight: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  rowDetail: { fontSize: 14, color: colors.mediumGray },
});
