import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import '@/shared/config/environment';
import { AuthProvider } from '@/features/auth/auth-provider';
import { LocationProvider } from '@/features/location/location-provider';

export default function RootLayout() {
  return (
    <AuthProvider>
      <LocationProvider>
        <StatusBar style="dark" />
        <Stack screenOptions={{ headerShown: false }} />
      </LocationProvider>
    </AuthProvider>
  );
}
