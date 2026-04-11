import React from 'react';
import {View, Text, StyleSheet, TouchableOpacity} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

function ChecklistItem({
  icon,
  text,
}: {
  icon: keyof typeof Ionicons.glyphMap;
  text: string;
}) {
  return (
    <View style={styles.checkRow}>
      <View style={styles.checkIconWrap}>
        <Ionicons name={icon} size={18} color={colors.wolfpackRed} />
      </View>
      <Text style={styles.checkText}>{text}</Text>
    </View>
  );
}

export default function ReadyToConnectScreen({ navigation }: any) {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.iconCircle}>
          <Ionicons name="bluetooth" size={60} color={colors.mediumGray} />
        </View>

        <Text style={styles.title}>Ready to{'\n'}Connect</Text>
        <Text style={styles.subtitle}>Let's get your hand connected!</Text>

        <View style={styles.deviceInfo}>
          <ChecklistItem
            icon="power"
            text="Make sure your hand is powered on"
          />
          <ChecklistItem
            icon="bluetooth"
            text="Bluetooth must be turned on"
          />
          <ChecklistItem
            icon="hand-left"
            text="Hold your hand close to the phone"
          />
        </View>

        <TouchableOpacity
          style={styles.button}
          onPress={() => navigation.navigate('Searching')}
        >
          <Text style={styles.buttonText}>Connect</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.white,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 40,
  },
  iconCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: colors.lightGray,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: colors.wolfpackRed,
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.darkGray,
    marginBottom: 24,
  },
  deviceInfo: {
    backgroundColor: colors.backgroundGray,
    borderRadius: 12,
    padding: 16,
    width: '100%',
    marginBottom: 30,
    gap: 12,
  },
  checkRow: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  checkIconWrap: {
    width: 32, height: 32, borderRadius: 16,
    backgroundColor: colors.white,
    alignItems: 'center', justifyContent: 'center',
  },
  checkText: { flex: 1, fontSize: 14, color: colors.darkGray, fontWeight: '500' },
  button: {
    backgroundColor: colors.wolfpackRed,
    paddingHorizontal: 50,
    paddingVertical: 14,
    borderRadius: 25,
    elevation: 3,
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  buttonText: {
    color: colors.white,
    fontSize: 18,
    fontWeight: '700',
  },
});
