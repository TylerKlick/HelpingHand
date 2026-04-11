import React, { useState } from 'react';
import {View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { colors } from '../theme';

type ShopGesture = {
  id: string;
  name: string;
  emoji: string;
  description: string;
  category: string;
  added: boolean;
};

const shopGestures: ShopGesture[] = [
  {
    id: 'open_hand',
    name: 'Open Hand',
    emoji: '🖐️',
    description: 'Fully open palm with fingers spread',
    category: 'Basic',
    added: true,
  },
  {
    id: 'closed_hand',
    name: 'Closed Hand',
    emoji: '✊',
    description: 'Fully closed fist',
    category: 'Basic',
    added: true,
  },
  {
    id: 'thumbs_up',
    name: 'Thumbs Up',
    emoji: '👍',
    description: 'Thumb extended upward, fingers closed',
    category: 'Basic',
    added: true,
  },
  {
    id: 'peace_sign',
    name: 'Peace Sign',
    emoji: '✌️',
    description: 'Index and middle finger extended',
    category: 'Basic',
    added: true,
  },
  {
    id: 'wolfpack',
    name: 'Wolfpack',
    emoji: '🤟',
    description: 'NC State Wolfpack hand sign',
    category: 'Special',
    added: true,
  },
  {
    id: 'point',
    name: 'Point',
    emoji: '👆',
    description: 'Index finger pointing forward',
    category: 'Basic',
    added: true,
  },
  {
    id: 'pinch',
    name: 'Pinch',
    emoji: '🤏',
    description: 'Thumb and index finger together',
    category: 'Advanced',
    added: false,
  },
  {
    id: 'wave',
    name: 'Wave',
    emoji: '👋',
    description: 'Side-to-side waving motion',
    category: 'Advanced',
    added: false,
  },
  {
    id: 'ok_sign',
    name: 'OK Sign',
    emoji: '👌',
    description: 'Thumb and index form circle, others extended',
    category: 'Advanced',
    added: false,
  },
];

export default function GestureShopScreen() {
  const [gestures, setGestures] = useState(shopGestures);

  const categories = [...new Set(gestures.map((g) => g.category))];

  const addGesture = (gestureId: string) => {
    setGestures((prev) =>
      prev.map((g) => (g.id === gestureId ? { ...g, added: true } : g))
    );
    Alert.alert('Gesture Added', 'This gesture has been added to your collection!');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Gesture Shop</Text>
        <Text style={styles.headerSubtitle}>Browse and add pre-configured gestures</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        {categories.map((category) => (
          <View key={category}>
            <Text style={styles.categoryTitle}>{category}</Text>
            {gestures
              .filter((g) => g.category === category)
              .map((gesture) => (
                <View key={gesture.id} style={styles.gestureCard}>
                  <View style={styles.gestureLeft}>
                    <Text style={styles.gestureEmoji}>{gesture.emoji}</Text>
                    <View style={styles.gestureInfo}>
                      <Text style={styles.gestureName}>{gesture.name}</Text>
                      <Text style={styles.gestureDesc}>{gesture.description}</Text>
                    </View>
                  </View>
                  {gesture.added ? (
                    <View style={styles.addedBadge}>
                      <Text style={styles.addedText}>Added</Text>
                    </View>
                  ) : (
                    <TouchableOpacity
                      style={styles.addButton}
                      onPress={() => addGesture(gesture.id)}
                    >
                      <Text style={styles.addButtonText}>+ Add</Text>
                    </TouchableOpacity>
                  )}
                </View>
              ))}
          </View>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.white,
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
  },
  headerSubtitle: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.8)',
    marginTop: 4,
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 40,
  },
  categoryTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: colors.darkGray,
    marginBottom: 12,
    marginTop: 8,
  },
  gestureCard: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: colors.backgroundGray,
    borderRadius: 14,
    padding: 14,
    marginBottom: 10,
  },
  gestureLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    gap: 12,
  },
  gestureEmoji: {
    fontSize: 32,
  },
  gestureInfo: {
    flex: 1,
  },
  gestureName: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.black,
  },
  gestureDesc: {
    fontSize: 12,
    color: colors.mediumGray,
    marginTop: 2,
  },
  addButton: {
    backgroundColor: colors.wolfpackRed,
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
  },
  addButtonText: {
    color: colors.white,
    fontSize: 14,
    fontWeight: '700',
  },
  addedBadge: {
    backgroundColor: colors.lightGray,
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
  },
  addedText: {
    color: colors.mediumGray,
    fontSize: 14,
    fontWeight: '600',
  },
});
