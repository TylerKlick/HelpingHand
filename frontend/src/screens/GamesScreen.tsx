import React from 'react';
import {View, Text, StyleSheet} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

export default function GamesScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Games</Text>
      </View>
      <View style={styles.content}>
        <Ionicons name="game-controller-outline" size={80} color={colors.lightGray} />
        <Text style={styles.title}>Coming Soon!</Text>
        <Text style={styles.subtitle}>
          Fun games to help you practice{'\n'}and train your gestures
        </Text>
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
    flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: 40, gap: 12,
  },
  title: { fontSize: 22, fontWeight: '700', color: colors.darkGray },
  subtitle: { fontSize: 14, color: colors.mediumGray, textAlign: 'center', lineHeight: 20 },
});
