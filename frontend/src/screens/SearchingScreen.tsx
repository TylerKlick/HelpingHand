import React, { useEffect } from 'react';
import { View, Text, StyleSheet, SafeAreaView, ActivityIndicator, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

export default function SearchingScreen({ navigation }: any) {
  useEffect(() => {
    // Simulate BLE scanning — in production this would use react-native-ble-plx
    const timer = setTimeout(() => {
      navigation.replace('Connected');
    }, 3000);
    return () => clearTimeout(timer);
  }, [navigation]);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.iconCircle}>
          <Ionicons name="bluetooth" size={60} color={colors.wolfpackRed} />
        </View>

        <Text style={styles.title}>Searching...</Text>
        <Text style={styles.subtitle}>Looking for your hand</Text>

        <ActivityIndicator size="large" color={colors.wolfpackRed} style={styles.spinner} />

        <TouchableOpacity style={styles.connectingButton} disabled>
          <Text style={styles.connectingText}>Connecting...</Text>
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
    backgroundColor: '#F0E6FF',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
  },
  title: {
    fontSize: 24,
    fontWeight: '800',
    color: colors.wolfpackRed,
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: colors.mediumGray,
    marginBottom: 20,
  },
  spinner: {
    marginBottom: 30,
  },
  connectingButton: {
    backgroundColor: colors.reynoldsRed,
    paddingHorizontal: 40,
    paddingVertical: 14,
    borderRadius: 25,
    opacity: 0.7,
  },
  connectingText: {
    color: colors.white,
    fontSize: 16,
    fontWeight: '700',
  },
});
