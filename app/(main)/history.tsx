import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { BookingApiError, getOrderHistory, type PassengerOrder } from '@/features/booking/api';
import { useAuth } from '@/features/auth/auth-provider';

const statusLabels: Record<string, string> = { completed: 'Завершён', cancelled: 'Отменён', searching: 'Ищем водителя', driver_assigned: 'Водитель назначен', driver_arriving: 'Водитель едет к вам', arrived: 'Водитель на месте', in_progress: 'Поездка началась' };

function formatPrice(amount: number, currency: string): string {
  return new Intl.NumberFormat('ru-RU', { style: 'currency', currency, maximumFractionDigits: 0 }).format(amount);
}

export default function HistoryScreen() {
  const { session, withAccessToken } = useAuth();
  const [orders, setOrders] = useState<PassengerOrder[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const loadHistory = useCallback(async () => {
    if (!session) return;
    setError(null);
    try { setOrders(await withAccessToken(getOrderHistory)); } catch (cause) { setError(cause instanceof BookingApiError ? cause.message : 'Не удалось загрузить историю заказов.'); } finally { setIsLoading(false); }
  }, [session, withAccessToken]);
  useEffect(() => { void loadHistory(); }, [loadHistory]);
  if (!session) return null;
  return <SafeAreaView style={styles.safeArea}><ScrollView contentContainerStyle={styles.content}>
    <Text style={styles.title}>История заказов</Text>
    {isLoading ? <ActivityIndicator style={styles.loader} /> : null}
    {!isLoading && orders.length === 0 ? <View style={styles.empty}><Text style={styles.emptyTitle}>Заказов пока нет</Text><Text style={styles.emptyText}>Здесь появятся завершённые и отменённые поездки.</Text></View> : null}
    {orders.map((order) => <View key={order.id} style={styles.card}><View style={styles.cardHeader}><Text style={styles.status}>{statusLabels[order.status] ?? order.status}</Text>{order.price !== null ? <Text style={styles.price}>{formatPrice(order.price, order.currency)}</Text> : null}</View><Text style={styles.routeLabel}>Откуда</Text><Text style={styles.address}>{order.pickupAddress || 'Адрес не указан'}</Text><Text style={styles.routeLabel}>Куда</Text><Text style={styles.address}>{order.destinationAddress || 'Адрес не указан'}</Text>{order.carClassName ? <Text style={styles.className}>{order.carClassName}</Text> : null}</View>)}
    {error ? <Text style={styles.error}>{error}</Text> : null}
    {!isLoading ? <Pressable onPress={() => void loadHistory()} style={styles.refresh}><Text style={styles.refreshText}>Обновить</Text></Pressable> : null}
  </ScrollView></SafeAreaView>;
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: '#ffffff' }, content: { padding: 24, paddingBottom: 40 }, title: { color: '#111111', fontSize: 30, fontWeight: '700' }, loader: { marginTop: 40 }, card: { borderColor: '#e5e7eb', borderRadius: 16, borderWidth: 1, marginTop: 16, padding: 18 }, cardHeader: { alignItems: 'center', flexDirection: 'row', justifyContent: 'space-between' }, status: { color: '#166534', fontSize: 16, fontWeight: '700' }, price: { color: '#111111', fontSize: 18, fontWeight: '700' }, routeLabel: { color: '#737373', fontSize: 12, marginTop: 16 }, address: { color: '#111111', fontSize: 16, lineHeight: 22, marginTop: 4 }, className: { color: '#525252', fontSize: 14, marginTop: 16 }, empty: { alignItems: 'center', borderColor: '#e5e7eb', borderRadius: 16, borderWidth: 1, marginTop: 24, padding: 24 }, emptyTitle: { color: '#111111', fontSize: 18, fontWeight: '600' }, emptyText: { color: '#666666', lineHeight: 21, marginTop: 8, textAlign: 'center' }, error: { color: '#b42318', lineHeight: 20, marginTop: 18 }, refresh: { alignItems: 'center', marginTop: 20, padding: 12 }, refreshText: { color: '#1d4ed8', fontWeight: '600' },
});
