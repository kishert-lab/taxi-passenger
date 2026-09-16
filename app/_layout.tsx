import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import '@/shared/config/environment';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="dark" />
      <Stack screenOptions={{ headerShown: false }} />
    </>
  );
}
