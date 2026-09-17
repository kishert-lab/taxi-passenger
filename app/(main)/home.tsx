import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { getCurrentOrder } from '@/features/booking/api';
import { useAuth } from '@/features/auth/auth-provider';

export default function HomeScreen() {
  const { session, logout, withAccessToken } = useAuth();
  const [hasCurrentOrder, setHasCurrentOrder] = useState(false);
  const [isLeaving, setIsLeaving] = useState(false);

  useEffect(() => {
    if (!session) {
      setHasCurrentOrder(false);
      return;
    }
    void withAccessToken(getCurrentOrder).then((order) => setHasCurrentOrder(order !== null)).catch(() => undefined);
  }, [session, withAccessToken]);

  if (!session) return null;

  async function handleLogout() {
    setIsLeaving(true);
    await logout();
    router.replace('/phone');
  }

  return <SafeAreaView style={styles.safeArea}><View style={styles.content}>
    <Text style={styles.title}>Здравствуйте, {session.passenger.name || 'пассажир'}</Text>
    <Text style={styles.phone}>{session.passenger.phone}</Text>
    <Pressable style={({ pressed }) => [styles.orderButton, pressed && styles.buttonPressed]} onPress={() => router.push('./booking')}><Text style={styles.buttonText}>Заказать такси</Text></Pressable>
    {hasCurrentOrder ? <Pressable style={styles.currentOrderButton} onPress={() => router.push('./order')}><Text style={styles.currentOrderText}>Открыть текущий заказ</Text></Pressable> : null}
    <Text style={styles.notice}>Адреса и класс автомобиля можно выбрать на следующем шаге.</Text>
    <Pressable style={({ pressed }) => [styles.logoutButton, (pressed || isLeaving) && styles.buttonPressed]} onPress={() => void handleLogout()} disabled={isLeaving}>{isLeaving ? <ActivityIndicator /> : <Text style={styles.logoutText}>Выйти</Text>}</Pressable>
  </View></SafeAreaView>;
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: '#ffffff' },
  content: { flex: 1, padding: 24, justifyContent: 'center' },
  title: { fontSize: 28, fontWeight: '700', color: '#111111' },
  phone: { color: '#666666', marginTop: 6, fontSize: 16 },
  orderButton: { height: 54, borderRadius: 12, backgroundColor: '#111111', justifyContent: 'center', alignItems: 'center', marginTop: 32 },
  currentOrderButton: { alignItems: 'center', borderColor: '#111111', borderRadius: 12, borderWidth: 1, height: 50, justifyContent: 'center', marginTop: 10 },
  currentOrderText: { color: '#111111', fontWeight: '600', fontSize: 16 },
  buttonPressed: { opacity: 0.72 },
  buttonText: { color: '#ffffff', fontWeight: '600', fontSize: 16 },
  notice: { color: '#666666', lineHeight: 21, marginTop: 12 },
  logoutButton: { alignItems: 'center', paddingVertical: 20, marginTop: 8 },
  logoutText: { color: '#1d4ed8', fontSize: 16 },
});
