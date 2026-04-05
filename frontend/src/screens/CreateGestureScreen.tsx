import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

const fingerNames = ['Thumb', 'Index', 'Middle', 'Ring', 'Pinky'];

type FingerPosition = {
  name: string;
  angle: number; // 0 = fully open, 180 = fully closed
};

export default function CreateGestureScreen({ navigation }: any) {
  const [gestureName, setGestureName] = useState('');
  const [fingers, setFingers] = useState<FingerPosition[]>(
    fingerNames.map((name) => ({ name, angle: 0 }))
  );
  const [isRecording, setIsRecording] = useState(false);

  const setFingerAngle = (index: number, angle: number) => {
    setFingers((prev) =>
      prev.map((f, i) => (i === index ? { ...f, angle } : f))
    );
  };

  const handleReadFromDevice = () => {
    // When Arduino is connected, this will read motor angles via BLE
    setIsRecording(true);
    Alert.alert(
      'Position Your Hand',
      'Move the prosthetic hand into the gesture position you want to save. The app will read the motor angles when you tap "Capture".',
      [
        {
          text: 'Cancel',
          onPress: () => setIsRecording(false),
          style: 'cancel',
        },
        {
          text: 'Capture',
          onPress: () => {
            // TODO: Read actual motor angles from Arduino via BLE
            // For now, simulate with random angles
            setFingers((prev) =>
              prev.map((f) => ({
                ...f,
                angle: Math.round(Math.random() * 180),
              }))
            );
            setIsRecording(false);
            Alert.alert('Captured!', 'Motor positions have been recorded.');
          },
        },
      ]
    );
  };

  const handleSave = () => {
    if (!gestureName.trim()) {
      Alert.alert('Name Required', 'Please enter a name for your gesture.');
      return;
    }
    // TODO: Save gesture to device via BLE and persist locally
    Alert.alert('Gesture Saved!', `"${gestureName}" has been added to your gestures.`, [
      { text: 'OK', onPress: () => navigation.goBack() },
    ]);
  };

  const getFingerLabel = (angle: number) => {
    if (angle === 0) return 'Open';
    if (angle === 180) return 'Closed';
    return `${angle}deg`;
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
          <Ionicons name="arrow-back" size={24} color={colors.white} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Create Gesture</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Gesture Name */}
        <Text style={styles.sectionTitle}>Gesture Name</Text>
        <TextInput
          style={styles.input}
          placeholder="e.g., Rock On, High Five..."
          placeholderTextColor={colors.mediumGray}
          value={gestureName}
          onChangeText={setGestureName}
        />

        {/* Read from Device */}
        <View style={styles.deviceSection}>
          <TouchableOpacity
            style={[styles.readButton, isRecording && styles.readButtonActive]}
            onPress={handleReadFromDevice}
          >
            <Ionicons
              name={isRecording ? 'radio-outline' : 'hand-left-outline'}
              size={22}
              color={colors.white}
            />
            <Text style={styles.readButtonText}>
              {isRecording ? 'Reading Motors...' : 'Read from Device'}
            </Text>
          </TouchableOpacity>
          <Text style={styles.helperText}>
            Position the hand physically, then tap to capture motor angles
          </Text>
        </View>

        {/* Manual Finger Controls */}
        <Text style={styles.sectionTitle}>Finger Positions</Text>
        <Text style={styles.helperText}>
          Adjust each finger manually, or use "Read from Device" above
        </Text>

        {fingers.map((finger, index) => (
          <View key={finger.name} style={styles.fingerRow}>
            <Text style={styles.fingerName}>{finger.name}</Text>
            <View style={styles.sliderContainer}>
              <TouchableOpacity
                style={styles.presetButton}
                onPress={() => setFingerAngle(index, 0)}
              >
                <Text style={styles.presetText}>Open</Text>
              </TouchableOpacity>

              <View style={styles.angleDisplay}>
                <Text style={styles.angleText}>{getFingerLabel(finger.angle)}</Text>
              </View>

              {/* Simple angle stepper */}
              <View style={styles.stepperRow}>
                <TouchableOpacity
                  style={styles.stepButton}
                  onPress={() => setFingerAngle(index, Math.max(0, finger.angle - 15))}
                >
                  <Ionicons name="remove" size={18} color={colors.wolfpackRed} />
                </TouchableOpacity>
                <TouchableOpacity
                  style={styles.stepButton}
                  onPress={() => setFingerAngle(index, Math.min(180, finger.angle + 15))}
                >
                  <Ionicons name="add" size={18} color={colors.wolfpackRed} />
                </TouchableOpacity>
              </View>

              <TouchableOpacity
                style={styles.presetButton}
                onPress={() => setFingerAngle(index, 180)}
              >
                <Text style={styles.presetText}>Closed</Text>
              </TouchableOpacity>
            </View>
          </View>
        ))}

        {/* Hand Preview */}
        <View style={styles.previewCard}>
          <Text style={styles.previewTitle}>Preview</Text>
          <View style={styles.previewFingers}>
            {fingers.map((finger) => (
              <View key={finger.name} style={styles.previewFinger}>
                <View
                  style={[
                    styles.previewBar,
                    { height: 60 - (finger.angle / 180) * 40 },
                  ]}
                />
                <Text style={styles.previewLabel}>{finger.name[0]}</Text>
              </View>
            ))}
          </View>
        </View>

        {/* Save Button */}
        <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
          <Text style={styles.saveButtonText}>Save Gesture</Text>
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
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  backButton: {
    padding: 4,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: '800',
    color: colors.white,
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 40,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: colors.black,
    marginBottom: 8,
    marginTop: 16,
  },
  input: {
    backgroundColor: colors.backgroundGray,
    borderRadius: 12,
    padding: 14,
    fontSize: 16,
    color: colors.black,
    borderWidth: 1,
    borderColor: colors.lightGray,
  },
  deviceSection: {
    marginTop: 20,
    alignItems: 'center',
  },
  readButton: {
    backgroundColor: colors.wolfpackRed,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingHorizontal: 24,
    paddingVertical: 14,
    borderRadius: 25,
    width: '100%',
    justifyContent: 'center',
  },
  readButtonActive: {
    backgroundColor: colors.reynoldsRed,
  },
  readButtonText: {
    color: colors.white,
    fontSize: 16,
    fontWeight: '700',
  },
  helperText: {
    fontSize: 13,
    color: colors.mediumGray,
    marginTop: 8,
    textAlign: 'center',
  },
  fingerRow: {
    backgroundColor: colors.backgroundGray,
    borderRadius: 12,
    padding: 14,
    marginTop: 10,
  },
  fingerName: {
    fontSize: 15,
    fontWeight: '700',
    color: colors.black,
    marginBottom: 8,
  },
  sliderContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  presetButton: {
    backgroundColor: colors.lightGray,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 8,
  },
  presetText: {
    fontSize: 12,
    fontWeight: '600',
    color: colors.darkGray,
  },
  angleDisplay: {
    backgroundColor: colors.white,
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 8,
    minWidth: 55,
    alignItems: 'center',
  },
  angleText: {
    fontSize: 14,
    fontWeight: '700',
    color: colors.wolfpackRed,
  },
  stepperRow: {
    flexDirection: 'row',
    gap: 4,
  },
  stepButton: {
    backgroundColor: colors.white,
    borderWidth: 1,
    borderColor: colors.wolfpackRed,
    borderRadius: 6,
    width: 30,
    height: 30,
    justifyContent: 'center',
    alignItems: 'center',
  },
  previewCard: {
    backgroundColor: colors.backgroundGray,
    borderRadius: 16,
    padding: 20,
    marginTop: 24,
    alignItems: 'center',
  },
  previewTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.mediumGray,
    marginBottom: 12,
  },
  previewFingers: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: 16,
    height: 80,
  },
  previewFinger: {
    alignItems: 'center',
    justifyContent: 'flex-end',
  },
  previewBar: {
    width: 20,
    backgroundColor: colors.wolfpackRed,
    borderRadius: 4,
    minHeight: 10,
  },
  previewLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: colors.darkGray,
    marginTop: 4,
  },
  saveButton: {
    backgroundColor: colors.wolfpackRed,
    borderRadius: 25,
    paddingVertical: 16,
    alignItems: 'center',
    marginTop: 24,
  },
  saveButtonText: {
    color: colors.white,
    fontSize: 18,
    fontWeight: '700',
  },
});
