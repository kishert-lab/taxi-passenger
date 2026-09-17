import { Redirect } from 'expo-router';
import { ActivityIndicator, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { useAuth } from '@/features/auth/auth-provider';

export default function IndexScreen() {
  const { isBootstrapping, session } = useAuth();
  if (isBootstrapping) {
    return <SafeAreaView style={styles.safeArea}><View style={styles.content}><ActivityIndicator size="large" color="#111111" /></View></SafeAreaView>;
  }
  return <Redirect href={session ? '/home' : '/phone'} />;
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: '#ffffff' },
  content: { alignItems: 'center', flex: 1, justifyContent: 'center' },
});
