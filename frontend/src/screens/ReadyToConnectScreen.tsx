import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

export default function ReadyToConnectScreen({ navigation }: any) {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.iconCircle}>
          <Ionicons name="bluetooth" size={60} color={colors.mediumGray} />
        </View>

        <Text style={styles.title}>Ready to{'\n'}Connect</Text>
        <Text style={styles.subtitle}>Make sure your device is turned on</Text>

        <View style={styles.deviceInfo}>
          <View style={styles.deviceRow}>
            <Text style={styles.deviceName}>Left Hand</Text>
          </View>
          <View style={styles.batteryRow}>
            <Text style={styles.batteryText}>Battery: 85%</Text>
            <View style={styles.statusDot} />
          </View>
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
  },
  deviceRow: {
    marginBottom: 4,
  },
  deviceName: {
    fontSize: 18,
    fontWeight: '700',
    color: colors.black,
  },
  batteryRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  batteryText: {
    fontSize: 14,
    color: colors.mediumGray,
  },
  statusDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: colors.batteryGreen,
    marginLeft: 8,
  },
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
