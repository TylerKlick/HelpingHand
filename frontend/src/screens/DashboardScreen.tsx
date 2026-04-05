import React from 'react';
import {View,Text, StyleSheet, SafeAreaView, TouchableOpacity, ScrollView} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

const menuItems = [
  { icon: 'hand-left-outline' as const, label: 'My Gestures', screen: 'MyGestures' },
  { icon: 'help-circle-outline' as const, label: 'Help', screen: 'Help'},
  { icon: 'heart-outline' as const, label: 'Health Monitor', screen: 'HealthMonitor' },
  { icon: 'download-outline' as const, label: 'Updates', screen: 'Updates' },
  { icon: 'settings-outline' as const, label: 'Settings', screen: 'Settings' },
  { icon: 'game-controller-outline' as const, label: 'Games', screen: 'Games' },
];

export default function DashboardScreen({ navigation }: any) {
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.headerTitle}>Dashboard</Text>
          <View style={styles.statusBar}>
            <View style={styles.statusBadge}>
              <View style={styles.connectedDot} />
              <Text style={styles.statusText}>Connected</Text>
            </View>
            <View style={styles.batteryBadge}>
              <Ionicons name="battery-full" size={16} color={colors.batteryGreen} />
              <Text style={styles.batteryText}>85%</Text>
            </View>
          </View>
        </View>

        {/* Active Gesture Display */}
        <View style={styles.activeGestureCard}>
          <Text style={styles.activeGestureLabel}>Active Gesture</Text>
          <Text style={styles.activeGestureName}>Open Hand</Text>
          <Text style={styles.activeGestureId}>Gesture ID: 1</Text>
        </View>

        {/* Menu Grid */}
        <View style={styles.grid}>
          {menuItems.map((item) => (
            <TouchableOpacity
              key={item.label}
              style={styles.gridItem}
              onPress={() => navigation.navigate(item.screen)}
            >
              <Ionicons name={item.icon} size={36} color={colors.wolfpackRed} />
              <Text style={styles.gridLabel}>{item.label}</Text>
            </TouchableOpacity>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.white,
  },
  scrollContent: {
    paddingBottom: 30,
  },
  header: {
    backgroundColor: colors.wolfpackRed,
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 20,
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 20,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: '800',
    color: colors.white,
    marginBottom: 12,
  },
  statusBar: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  connectedDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: colors.batteryGreen,
    marginRight: 6,
  },
  statusText: {
    color: colors.white,
    fontSize: 13,
    fontWeight: '600',
  },
  batteryBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    gap: 4,
  },
  batteryText: {
    color: colors.white,
    fontSize: 13,
    fontWeight: '600',
  },
  activeGestureCard: {
    margin: 20,
    backgroundColor: colors.backgroundGray,
    borderRadius: 16,
    padding: 20,
    borderLeftWidth: 4,
    borderLeftColor: colors.wolfpackRed,
  },
  activeGestureLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: colors.mediumGray,
    textTransform: 'uppercase',
    letterSpacing: 1,
    marginBottom: 4,
  },
  activeGestureName: {
    fontSize: 22,
    fontWeight: '700',
    color: colors.black,
  },
  activeGestureId: {
    fontSize: 13,
    color: colors.mediumGray,
    marginTop: 2,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: 16,
    gap: 12,
  },
  gridItem: {
    width: '47%',
    backgroundColor: colors.backgroundGray,
    borderRadius: 16,
    paddingVertical: 28,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  gridLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.darkGray,
  },
});
