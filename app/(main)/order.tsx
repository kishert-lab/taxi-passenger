import { router } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { useAuth } from '@/features/auth/auth-provider';
import { BookingApiError, cancelOrder, getCurrentOrder, type PassengerOrder } from '@/features/booking/api';

const statusLabels: Record<string, string> = {
  searching: 'Ищем водителя', driver_assigned: 'Водитель назначен', driver_arriving: 'Водитель едет к вам', arrived: 'Водитель на месте', in_progress: 'Поездка началась', completed: 'Поездка завершена', cancelled: 'Заказ отменён',
};

function formatPrice(amount: number, currency: string): string {
  return new Intl.NumberFormat('ru-RU', { style: 'currency', currency, maximumFractionDigits: 0 }).format(amount);
}

export default function CurrentOrderScreen() {
  const { session, withAccessToken } = useAuth();
  const [order, setOrder] = useState<PassengerOrder | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isCancelling, setIsCancelling] = useState(false);
  const [reason, setReason] = useState('Передумал');
  const [error, setError] = useState<string | null>(null);

  const loadOrder = useCallback(async () => {
    if (!session) return;
    setError(null);
    try {
      setOrder(await withAccessToken(getCurrentOrder));
    } catch (cause) {
      setError(cause instanceof BookingApiError ? cause.message : 'Не удалось получить состояние заказа.');
    } finally {
      setIsLoading(false);
    }
  }, [session, withAccessToken]);

  useEffect(() => { void loadOrder(); }, [loadOrder]);
  if (!session) return null;

  async function handleCancel() {
    if (!session || !order || !reason.trim()) return;
    setError(null);
    setIsCancelling(true);
    try {
      setOrder(await withAccessToken((accessToken) => cancelOrder(accessToken, order.id, reason.trim())));
    } catch (cause) {
      setError(cause instanceof BookingApiError ? cause.message : 'Не удалось отменить заказ.');
    } finally {
      setIsCancelling(false);
    }
  }

  return <SafeAreaView style={styles.safeArea}><ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
    <Pressable onPress={() => router.back()} hitSlop={12}><Text style={styles.back}>‹ Назад</Text></Pressable>
    <Text style={styles.title}>Текущий заказ</Text>
    {isLoading ? <ActivityIndicator style={styles.loader} /> : null}
    {!isLoading && !order ? <View style={styles.empty}><Text style={styles.emptyTitle}>Активного заказа нет</Text><Pressable onPress={() => router.replace('./booking')} style={styles.orderButton}><Text style={styles.orderButtonText}>Заказать такси</Text></Pressable></View> : null}
    {order ? <View style={styles.card}><Text style={styles.status}>{statusLabels[order.status] ?? order.status}</Text><Text style={styles.routeLabel}>Откуда</Text><Text style={styles.address}>{order.pickupAddress || 'Адрес уточняется'}</Text><Text style={styles.routeLabel}>Куда</Text><Text style={styles.address}>{order.destinationAddress || 'Адрес уточняется'}</Text>{order.price !== null ? <Text style={styles.price}>{formatPrice(order.price, order.currency)}</Text> : null}{order.etaSeconds !== null ? <Text style={styles.eta}>Подача примерно через {Math.ceil(order.etaSeconds / 60)} мин.</Text> : null}{order.driver ? <View style={styles.driver}><Text style={styles.driverTitle}>{order.driver.name}{order.driver.rating !== null ? ` · ${order.driver.rating.toFixed(1)} ★` : ''}</Text>{order.car ? <Text style={styles.driverText}>{order.car.title}{order.car.plateNumber ? ` · ${order.car.plateNumber}` : ''}</Text> : null}{order.driver.phone ? <Text style={styles.driverText}>{order.driver.phone}</Text> : null}</View> : null}{order.allowedActions.includes('cancel') ? <View style={styles.cancel}><Text style={styles.cancelTitle}>Отменить заказ</Text><TextInput value={reason} onChangeText={setReason} style={styles.reason} maxLength={300} placeholder="Причина отмены" /><Pressable disabled={isCancelling || !reason.trim()} onPress={() => void handleCancel()} style={({ pressed }) => [styles.cancelButton, (pressed || isCancelling || !reason.trim()) && styles.disabled]}>{isCancelling ? <ActivityIndicator color="#b42318" /> : <Text style={styles.cancelButtonText}>Отменить</Text>}</Pressable></View> : null}</View> : null}
    {error ? <Text style={styles.error}>{error}</Text> : null}
    {!isLoading ? <Pressable onPress={() => void loadOrder()} style={styles.refresh}><Text style={styles.refreshText}>Обновить состояние</Text></Pressable> : null}
  </ScrollView></SafeAreaView>;
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: '#ffffff' }, content: { padding: 24, paddingBottom: 40 }, back: { color: '#1d4ed8', fontSize: 16, marginBottom: 22 }, title: { color: '#111111', fontSize: 30, fontWeight: '700' }, loader: { marginTop: 40 }, card: { borderColor: '#e5e7eb', borderRadius: 16, borderWidth: 1, marginTop: 24, padding: 20 }, status: { color: '#166534', fontSize: 18, fontWeight: '700', marginBottom: 22 }, routeLabel: { color: '#666666', fontSize: 13, marginTop: 14 }, address: { color: '#111111', fontSize: 16, lineHeight: 22, marginTop: 4 }, price: { color: '#111111', fontSize: 26, fontWeight: '700', marginTop: 24 }, eta: { color: '#666666', marginTop: 6 }, driver: { backgroundColor: '#f3f4f6', borderRadius: 12, marginTop: 22, padding: 14 }, driverTitle: { color: '#111111', fontSize: 17, fontWeight: '700' }, driverText: { color: '#4b5563', marginTop: 5 }, cancel: { borderTopColor: '#e5e7eb', borderTopWidth: 1, marginTop: 24, paddingTop: 20 }, cancelTitle: { color: '#111111', fontSize: 17, fontWeight: '700', marginBottom: 10 }, reason: { borderColor: '#d4d4d4', borderRadius: 12, borderWidth: 1, color: '#111111', height: 50, paddingHorizontal: 14 }, cancelButton: { alignItems: 'center', borderColor: '#b42318', borderRadius: 12, borderWidth: 1, height: 48, justifyContent: 'center', marginTop: 12 }, cancelButtonText: { color: '#b42318', fontWeight: '700' }, disabled: { opacity: 0.45 }, error: { color: '#b42318', lineHeight: 20, marginTop: 18 }, refresh: { alignItems: 'center', marginTop: 24, padding: 12 }, refreshText: { color: '#1d4ed8', fontWeight: '600' }, empty: { alignItems: 'center', borderColor: '#e5e7eb', borderRadius: 16, borderWidth: 1, marginTop: 24, padding: 24 }, emptyTitle: { color: '#111111', fontSize: 18, fontWeight: '600' }, orderButton: { alignItems: 'center', backgroundColor: '#111111', borderRadius: 12, height: 50, justifyContent: 'center', marginTop: 18, width: '100%' }, orderButtonText: { color: '#ffffff', fontWeight: '700' },
});
