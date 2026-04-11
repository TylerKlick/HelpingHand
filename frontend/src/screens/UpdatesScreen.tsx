import React from 'react';
import {View, Text, StyleSheet, TouchableOpacity} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

export default function UpdatesScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Updates</Text>
      </View>
      <View style={styles.content}>
        <View style={styles.iconCircle}>
          <Ionicons name="checkmark-circle" size={60} color={colors.batteryGreen} />
        </View>
        <Text style={styles.title}>You're up to date!</Text>
        <Text style={styles.subtitle}>Firmware version 1.0.0</Text>
        <TouchableOpacity style={styles.button}>
          <Text style={styles.buttonText}>Check for Updates</Text>
        </TouchableOpacity>
      </View>
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
  content: {
    flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: 40,
  },
  iconCircle: { marginBottom: 16 },
  title: { fontSize: 22, fontWeight: '700', color: colors.black, marginBottom: 4 },
  subtitle: { fontSize: 14, color: colors.mediumGray, marginBottom: 30 },
  button: {
    backgroundColor: colors.wolfpackRed, paddingHorizontal: 30, paddingVertical: 12,
    borderRadius: 25,
  },
  buttonText: { color: colors.white, fontSize: 16, fontWeight: '700' },
});
