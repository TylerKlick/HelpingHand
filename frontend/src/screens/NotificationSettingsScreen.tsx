import React, { useCallback, useEffect, useState } from 'react';
import {View, Text, StyleSheet, Switch, TouchableOpacity, ScrollView, Linking, Platform, Alert} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import {Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';
import {notificationService, NOTIFICATION_TYPES, NotificationType } from '../services/NotificationService';

export default function NotificationSettingsScreen({ navigation }: any) {
  const [permissionStatus, setPermissionStatus] = useState<
    'granted' | 'denied' | 'undetermined' | 'loading' >('loading');
  const [prefs, setPrefs] = useState<Record<NotificationType, boolean>>(notificationService.getPrefs());

  const refreshPermission = useCallback(async () => {
    const status = await notificationService.getPermissionStatus();
    setPermissionStatus(status);
    setPrefs(notificationService.getPrefs());
  }, []);

  useEffect(() => {
    refreshPermission();
  }, [refreshPermission]);

  const handleRequestPermission = async () => {
    const granted = await notificationService.requestPermission();
    await refreshPermission();
    if (!granted) {
      Alert.alert(
        'Permission Denied',
        'To receive notifications, go to your phone\'s Settings and enable notifications for Helping Hands.',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Open Settings', onPress: () => Linking.openSettings() },
        ],
      );
    }
  };

  const handleToggle = async (type: NotificationType, value: boolean) => {
    setPrefs((prev) => ({ ...prev, [type]: value }));
    await notificationService.setPref(type, value);
  };

  const isGranted = permissionStatus === 'granted';

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Ionicons name="chevron-back" size={26} color={colors.white} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Notifications</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        {/* Permission banner */}
        {permissionStatus !== 'loading' && (
          <View
            style={[
              styles.permissionCard,
              { backgroundColor: isGranted ? '#E8F5E9' : '#FFF8E1' },
            ]}
          >
            <Ionicons name={isGranted ? 'checkmark-circle' : 'notifications-off-outline'} size={28} color={isGranted ? colors.batteryGreen : colors.warning}/>
            <View style={{ flex: 1 }}>
              <Text style={[styles.permissionTitle,{ color: isGranted ? colors.batteryGreen : colors.warning }]}>
                {isGranted ? 'Notifications Enabled' : 'Notifications Off'}
              </Text>
              <Text style={styles.permissionDesc}>
                {isGranted
                  ? 'You\'ll receive alerts based on the settings below.'
                  : permissionStatus === 'denied'
                  ? 'Tap "Open Settings" to enable notifications for this app.'
                  : 'Tap below to allow Helping Hands to send you alerts.'}
              </Text>
            </View>
            {!isGranted && (
              <TouchableOpacity
                style={styles.permissionBtn}
                onPress={
                  permissionStatus === 'denied'
                    ? () => Linking.openSettings()
                    : handleRequestPermission
                }
              >
                <Text style={styles.permissionBtnText}>
                  {permissionStatus === 'denied' ? 'Open Settings' : 'Enable'}
                </Text>
              </TouchableOpacity>
            )}
          </View>
        )}

        {/* Notification type toggles */}
        <Text style={styles.sectionLabel}>NOTIFICATION TYPES</Text>
        <View style={styles.card}>
          {NOTIFICATION_TYPES.map((type, index) => (
            <View key={type.key}>
              {index > 0 && <View style={styles.divider} />}
              <View style={styles.row}>
                <View style={styles.rowText}>
                  <Text style={[styles.rowLabel, !isGranted && styles.dimmed]}>
                    {type.label}
                  </Text>
                  <Text style={[styles.rowDesc, !isGranted && styles.dimmed]}>
                    {type.desc}
                  </Text>
                </View>
                <Switch
                  value={isGranted ? prefs[type.key] : false}
                  onValueChange={(v) => handleToggle(type.key, v)}
                  disabled={!isGranted}
                  trackColor={{
                    false: colors.lightGray,
                    true: colors.wolfpackRed,
                  }}
                  thumbColor={colors.white}
                  ios_backgroundColor={colors.lightGray}
                />
              </View>
            </View>
          ))}
        </View>
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
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  backBtn: { padding: 4 },
  headerTitle: { fontSize: 26, fontWeight: '800', color: colors.white },
  content: { padding: 20, gap: 14, paddingBottom: 40 },

  permissionCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    borderRadius: 14,
    padding: 16,
  },
  permissionTitle: { fontSize: 15, fontWeight: '800', marginBottom: 2 },
  permissionDesc: { fontSize: 12, color: colors.darkGray, lineHeight: 16 },
  permissionBtn: {
    backgroundColor: colors.wolfpackRed,
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 20,
  },
  permissionBtnText: { color: colors.white, fontSize: 13, fontWeight: '700' },

  sectionLabel: {
    fontSize: 12,
    fontWeight: '700',
    color: colors.mediumGray,
    letterSpacing: 1,
    marginBottom: -4,
  },
  card: {
    backgroundColor: colors.backgroundGray,
    borderRadius: 14,
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  divider: { height: 1, backgroundColor: colors.lightGray },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    gap: 12,
  },
  rowText: { flex: 1 },
  rowLabel: { fontSize: 15, fontWeight: '600', color: colors.black },
  rowDesc: { fontSize: 12, color: colors.mediumGray, marginTop: 2 },
  dimmed: { opacity: 0.45 },
});
