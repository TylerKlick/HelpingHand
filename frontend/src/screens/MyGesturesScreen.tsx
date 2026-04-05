import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { colors } from '../theme';

type Gesture = {
  id: number;
  name: string;
  emoji: string;
  active: boolean;
};

const initialGestures: Gesture[] = [
  { id: 1, name: 'Open Hand', emoji: '🖐️', active: true },
  { id: 2, name: 'Closed Hand', emoji: '✊', active: true },
  { id: 3, name: 'Thumbs Up', emoji: '👍', active: false },
  { id: 4, name: 'Peace Sign', emoji: '✌️', active: true },
  { id: 5, name: 'Wolfpack', emoji: '🤟', active: true },
  { id: 6, name: 'Point', emoji: '👆', active: false },
];

export default function MyGesturesScreen({ navigation }: any) {
  const [gestures, setGestures] = useState(initialGestures);

  const toggleGesture = (gestureId: number) => {
    setGestures((prev) =>
      prev.map((g) => (g.id === gestureId ? { ...g, active: !g.active } : g))
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>My Gestures</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        {gestures.map((gesture) => (
          <TouchableOpacity
            key={gesture.id}
            style={[styles.gestureRow, gesture.active && styles.gestureRowActive]}
            onPress={() => toggleGesture(gesture.id)}
          >
            <View style={styles.gestureLeft}>
              <Text style={styles.gestureEmoji}>{gesture.emoji}</Text>
              <View>
                <Text style={styles.gestureName}>{gesture.name}</Text>
                <Text style={styles.gestureId}>ID: {gesture.id}</Text>
              </View>
            </View>
            <View
              style={[
                styles.idBadge,
                gesture.active ? styles.idBadgeActive : styles.idBadgeInactive,
              ]}
            >
              <Text
                style={[
                  styles.idBadgeText,
                  gesture.active ? styles.idBadgeTextActive : styles.idBadgeTextInactive,
                ]}
              >
                {gesture.active ? `#${gesture.id}` : 'OFF'}
              </Text>
            </View>
          </TouchableOpacity>
        ))}

        <TouchableOpacity
          style={styles.createButton}
          onPress={() => navigation.navigate('CreateGesture')}
        >
          <Text style={styles.moreButtonText}>+ Create Custom Gesture</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.moreButton}
          onPress={() => navigation.navigate('GestureShop')}
        >
          <Text style={styles.moreButtonText}>+ More Gestures</Text>
        </TouchableOpacity>
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
  scrollContent: {
    padding: 20,
    gap: 12,
  },
  gestureRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: colors.backgroundGray,
    borderRadius: 14,
    padding: 16,
    borderLeftWidth: 4,
    borderLeftColor: colors.lightGray,
  },
  gestureRowActive: {
    borderLeftColor: colors.wolfpackRed,
    backgroundColor: '#FFF5F5',
  },
  gestureLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
  },
  gestureEmoji: {
    fontSize: 32,
  },
  gestureName: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.black,
  },
  gestureId: {
    fontSize: 12,
    color: colors.mediumGray,
    marginTop: 2,
  },
  idBadge: {
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 20,
    minWidth: 50,
    alignItems: 'center',
  },
  idBadgeActive: {
    backgroundColor: colors.wolfpackRed,
  },
  idBadgeInactive: {
    backgroundColor: colors.lightGray,
  },
  idBadgeText: {
    fontSize: 14,
    fontWeight: '700',
  },
  idBadgeTextActive: {
    color: colors.white,
  },
  idBadgeTextInactive: {
    color: colors.mediumGray,
  },
  createButton: {
    backgroundColor: colors.black,
    borderRadius: 25,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: 8,
  },
  moreButton: {
    backgroundColor: colors.wolfpackRed,
    borderRadius: 25,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: 8,
  },
  moreButtonText: {
    color: colors.white,
    fontSize: 16,
    fontWeight: '700',
  },
});
