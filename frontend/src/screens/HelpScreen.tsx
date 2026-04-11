import React from 'react';
import {View, Text, StyleSheet, ScrollView, TouchableOpacity} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

const helpTopics = [
  { icon: 'hand-left' as const, title: 'Using Gestures', desc: 'Learn about available gestures and how to activate them' },
  { icon: 'construct' as const, title: 'Troubleshooting', desc: 'Common issues and how to fix them' },
  { icon: 'battery-charging' as const, title: 'Battery & Charging', desc: 'Charging instructions and battery care' },
  { icon: 'bug' as const, title: 'Report a Bug', desc: 'Let us know if something isn\'t working' },
];

export default function HelpScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Help</Text>
      </View>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {helpTopics.map((topic) => (
          <TouchableOpacity key={topic.title} style={styles.card}>
            <Ionicons name={topic.icon} size={28} color={colors.wolfpackRed} />
            <View style={styles.cardText}>
              <Text style={styles.cardTitle}>{topic.title}</Text>
              <Text style={styles.cardDesc}>{topic.desc}</Text>
            </View>
            <Ionicons name="chevron-forward" size={18} color={colors.mediumGray} />
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
    paddingHorizontal: 20, paddingTop: 16, paddingBottom: 20,
    borderBottomLeftRadius: 20, borderBottomRightRadius: 20,
  },
  headerTitle: { fontSize: 28, fontWeight: '800', color: colors.white },
  scrollContent: { padding: 20, gap: 12 },
  card: {
    flexDirection: 'row', alignItems: 'center', gap: 14,
    backgroundColor: colors.backgroundGray, borderRadius: 14, padding: 16,
  },
  cardText: { flex: 1 },
  cardTitle: { fontSize: 16, fontWeight: '700', color: colors.black },
  cardDesc: { fontSize: 13, color: colors.mediumGray, marginTop: 2 },
});
