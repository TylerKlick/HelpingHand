import React, { useCallback, useEffect, useState } from 'react';
import {View, Text, StyleSheet, TouchableOpacity, ScrollView} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';
import { bleService, ConnectionState } from '../services/BLEService';
import { notificationService } from '../services/NotificationService';

export default function SettingsScreen({ navigation }: any) {
  const [state, setState] = useState<ConnectionState>(bleService.getState());
  const [notifStatus, setNotifStatus] = useState<string>('...');

  useEffect(() => {
    const unsub = bleService.onStateChange(setState);
    return () => unsub();
  }, []);

  // Refresh notification status 
  useFocusEffect(
    useCallback(() => {
      notificationService.getPermissionStatus().then((status) => {
        if (status === 'granted') setNotifStatus('On');
        else if (status === 'denied') setNotifStatus('Off');
        else setNotifStatus('Not set');
      });
    }, []),
  );

  const bluetoothLabel =
    state === 'validated'
      ? 'Connected'
      : state === 'connecting' || state === 'validating'
      ? 'Connecting...'
      : state === 'scanning'
      ? 'Searching...'
      : 'Not Connected';
  const bluetoothColor = state === 'validated' ? colors.batteryGreen : colors.warning;

  type Item = {
    icon: keyof typeof Ionicons.glyphMap;
    label: string;
    detail: string;
    detailColor?: string;
    onPress?: () => void;
  };

  const items: Item[] = [
    {
      icon: 'bluetooth-outline',
      label: 'Bluetooth',
      detail: bluetoothLabel,
      detailColor: bluetoothColor,
      onPress: () => navigation.navigate('BluetoothSettings'),
    },
    { icon: 'notifications-outline', label: 'Notifications', detail: notifStatus, onPress: () => navigation.navigate('NotificationSettings'),},
    { icon: 'hand-left-outline', label: 'Hand Preferences', detail: 'Left Hand' },
    {
      icon: 'analytics-outline',
      label: 'Data & Privacy',
      detail: '',
      onPress: () => navigation.navigate('DataPrivacy'),
    },
    { icon: 'information-circle-outline', label: 'About', detail: 'v1.0.0' },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Settings</Text>
      </View>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {items.map((item) => (
          <TouchableOpacity
            key={item.label}
            style={styles.row}
            onPress={item.onPress}
            disabled={!item.onPress}
            activeOpacity={item.onPress ? 0.6 : 1}
          >
            <View style={styles.rowLeft}>
              <Ionicons name={item.icon} size={22} color={colors.wolfpackRed} />
              <Text style={styles.rowLabel}>{item.label}</Text>
            </View>
            <View style={styles.rowRight}>
              {!!item.detail && (
                <Text style={[styles.rowDetail, item.detailColor && { color: item.detailColor, fontWeight: '700' }]}>
                  {item.detail}
                </Text>
              )}
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
