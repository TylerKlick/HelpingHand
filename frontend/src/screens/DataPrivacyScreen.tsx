import React from 'react';
import {View, Text, StyleSheet, ScrollView, TouchableOpacity} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

/**
 * Data & Privacy 
 *
 * - If we add cloud sync, accounts, analytics, etc add a section 
 * - If we add a backend, add the destination + what is sent.
 * - If we change BLE behavior update under "Bluetooth".
 */
export default function DataPrivacyScreen({ navigation }: any) {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Ionicons name="chevron-back" size={26} color={colors.white} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Data & Privacy</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.intro}>
          The Helping Hands Project app is built for kids and their families. We keep things simple
          and private — here is exactly what happens with your data.
        </Text>

        <Section title="What we collect" icon="document-text-outline">
          <Bullet>
            <Bold>Nothing leaves your phone.</Bold> The app does not have user accounts, does not
            send data to any server, and does not include analytics or crash reporting.
          </Bullet>
          <Bullet>
            <Bold>Sensor data from your hand</Bold> (IMU motion + sEMG muscle signals) is received
            over Bluetooth while you are connected. It is shown live in the Health Monitor and is
            not saved to disk or shared.
          </Bullet>
          <Bullet>
            <Bold>Your custom gestures</Bold> are stored only on this device. They never leave your
            phone.
          </Bullet>
        </Section>

        <Section title="Bluetooth" icon="bluetooth-outline">
          <Bullet>
            The app uses Bluetooth Low Energy (BLE) to talk to your prosthetic hand. It only looks
            for devices that advertise the Helping Hand service ID — it ignores headphones,
            watches, and other Bluetooth gadgets nearby.
          </Bullet>
          <Bullet>
            iOS and Android ask permission for Bluetooth the first time you use the app. You can
            change this later in your phone's Settings app.
          </Bullet>
          <Bullet>
            On Android, location permission may be requested. This is required by the Android
            operating system for any BLE scanning. We do not read or store your location.
          </Bullet>
        </Section>

        <Section title="What we do NOT do" icon="shield-checkmark-outline">
          <Bullet>No accounts, no logins, no passwords.</Bullet>
          <Bullet>No analytics, tracking pixels, or third-party SDKs.</Bullet>
          <Bullet>No advertising.</Bullet>
          <Bullet>No cloud backup of sensor data or gestures.</Bullet>
          <Bullet>No microphone, camera, contacts, or photo access.</Bullet>
        </Section>

        <Section title="Firmware updates" icon="download-outline">
          <Bullet>
            When you install a firmware update, the app sends the new firmware file directly to
            your hand over Bluetooth. The file is bundled with the app — nothing is downloaded from
            the internet during the update.
          </Bullet>
        </Section>

        <Section title="Kids and families" icon="people-outline">
          <Bullet>
            Helping Hands is designed for children, including kids under 13. Because the app does
            not collect any personal information, it does not require parental consent under COPPA
            — but we encourage parents to set up the device with their child the first time.
          </Bullet>
        </Section>

        <Section title="About this project" icon="information-circle-outline">
          <Bullet>
            Helping Hands is a student project at North Carolina State University. The source code
            is part of an academic effort to build affordable, kid-friendly prosthetics.
          </Bullet>
          <Bullet>
            If you have a question about your data, ask a project team member or your hand's
            provider.
          </Bullet>
        </Section>

        <Text style={styles.footer}>
          Last updated: April 2026{'\n'}
          Helping Hands Project at NC State
        </Text>
      </ScrollView>
    </SafeAreaView>
  );
}

function Section({
  title,
  icon,
  children,
}: {
  title: string;
  icon: keyof typeof Ionicons.glyphMap;
  children: React.ReactNode;
}) {
  return (
    <View style={styles.section}>
      <View style={styles.sectionHeader}>
        <Ionicons name={icon} size={20} color={colors.wolfpackRed} />
        <Text style={styles.sectionTitle}>{title}</Text>
      </View>
      <View style={styles.sectionBody}>{children}</View>
    </View>
  );
}

function Bullet({ children }: { children: React.ReactNode }) {
  return (
    <View style={styles.bullet}>
      <Text style={styles.bulletDot}>•</Text>
      <Text style={styles.bulletText}>{children}</Text>
    </View>
  );
}

function Bold({ children }: { children: React.ReactNode }) {
  return <Text style={{ fontWeight: '700', color: colors.darkGray }}>{children}</Text>;
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.white },
  header: {
    backgroundColor: colors.wolfpackRed,
    paddingHorizontal: 20, paddingTop: 16, paddingBottom: 20,
    borderBottomLeftRadius: 20, borderBottomRightRadius: 20,
    flexDirection: 'row', alignItems: 'center', gap: 6,
  },
  backBtn: { padding: 4 },
  headerTitle: { fontSize: 26, fontWeight: '800', color: colors.white },

  content: { padding: 20, gap: 18, paddingBottom: 40 },
  intro: { fontSize: 14, color: colors.darkGray, lineHeight: 20 },

  section: {
    backgroundColor: colors.backgroundGray,
    borderRadius: 14,
    padding: 16,
    gap: 10,
  },
  sectionHeader: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  sectionTitle: { fontSize: 15, fontWeight: '800', color: colors.darkGray },
  sectionBody: { gap: 8 },

  bullet: { flexDirection: 'row', gap: 8 },
  bulletDot: { fontSize: 14, color: colors.wolfpackRed, lineHeight: 20 },
  bulletText: { flex: 1, fontSize: 13, color: colors.darkGray, lineHeight: 20 },

  footer: {
    fontSize: 11, color: colors.mediumGray, textAlign: 'center', marginTop: 8,
  },
});
