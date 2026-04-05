import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

// Screens
import WelcomeScreen from '../screens/WelcomeScreen';
import ReadyToConnectScreen from '../screens/ReadyToConnectScreen';
import SearchingScreen from '../screens/SearchingScreen';
import ConnectedScreen from '../screens/ConnectedScreen';
import DashboardScreen from '../screens/DashboardScreen';
import MyGesturesScreen from '../screens/MyGesturesScreen';
import GestureShopScreen from '../screens/GestureShopScreen';
import SettingsScreen from '../screens/SettingsScreen';
import HelpScreen from '../screens/HelpScreen';
import HealthMonitorScreen from '../screens/HealthMonitorScreen';
import UpdatesScreen from '../screens/UpdatesScreen';
import GamesScreen from '../screens/GamesScreen';
import CreateGestureScreen from '../screens/CreateGestureScreen';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

function DashboardTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor: colors.wolfpackRed,
        tabBarInactiveTintColor: colors.mediumGray,
        tabBarStyle: {
          backgroundColor: colors.white,
          borderTopColor: colors.lightGray,
          paddingBottom: 5,
          height: 60,
        },
        tabBarIcon: ({ color, size }) => {
          let iconName: keyof typeof Ionicons.glyphMap = 'home';
          if (route.name === 'DashboardTab') iconName = 'grid-outline';
          if (route.name === 'MyGesturesTab') iconName = 'hand-left-outline';
          if (route.name === 'HealthTab') iconName = 'heart-outline';
          if (route.name === 'SettingsTab') iconName = 'settings-outline';
          return <Ionicons name={iconName} size={size} color={color} />;
        },
      })}
    >
      <Tab.Screen name="DashboardTab" component={DashboardStack} options={{ title: 'Home' }} />
      <Tab.Screen name="MyGesturesTab" component={GestureStack} options={{ title: 'Gestures' }} />
      <Tab.Screen name="HealthTab" component={HealthMonitorScreen} options={{ title: 'Health' }} />
      <Tab.Screen name="SettingsTab" component={SettingsScreen} options={{ title: 'Settings' }} />
    </Tab.Navigator>
  );
}

function DashboardStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="DashboardHome" component={DashboardScreen} />
      <Stack.Screen name="MyGestures" component={MyGesturesScreen} />
      <Stack.Screen name="GestureShop" component={GestureShopScreen} />
      <Stack.Screen name="Help" component={HelpScreen} />
      <Stack.Screen name="HealthMonitor" component={HealthMonitorScreen} />
      <Stack.Screen name="Updates" component={UpdatesScreen} />
      <Stack.Screen name="Settings" component={SettingsScreen} />
      <Stack.Screen name="Games" component={GamesScreen} />
      <Stack.Screen name="CreateGesture" component={CreateGestureScreen} />
    </Stack.Navigator>
  );
}

function GestureStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="MyGesturesHome" component={MyGesturesScreen} />
      <Stack.Screen name="GestureShop" component={GestureShopScreen} />
      <Stack.Screen name="CreateGesture" component={CreateGestureScreen} />
    </Stack.Navigator>
  );
}

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        <Stack.Screen name="Welcome" component={WelcomeScreen} />
        <Stack.Screen name="ReadyToConnect" component={ReadyToConnectScreen} />
        <Stack.Screen name="Searching" component={SearchingScreen} />
        <Stack.Screen name="Connected" component={ConnectedScreen} />
        {/* Main App with tabs */}
        <Stack.Screen name="Dashboard" component={DashboardTabs} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
