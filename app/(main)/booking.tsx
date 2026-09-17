import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { useAuth } from '@/features/auth/auth-provider';
import { BookingApiError, createOrder, estimateRoute, getCarClasses, searchAddresses, type Address, type CarClass, type CreatedOrder, type PaymentType, type RouteEstimate } from '@/features/booking/api';
import { getCurrentAddress, LocationError } from '@/features/location/location-service';
import { useLocation } from '@/features/location/location-provider';

type AddressTarget = 'pickup' | 'destination';

function formatPrice(price: number, currency: string): string {
  return new Intl.NumberFormat('ru-RU', { style: 'currency', currency, maximumFractionDigits: 0 }).format(price);
}

export default function BookingScreen() {
  const { session, withAccessToken } = useAuth();
  const { location } = useLocation();
  const [pickupQuery, setPickupQuery] = useState('');
  const [destinationQuery, setDestinationQuery] = useState('');
  const [pickup, setPickup] = useState<Address | null>(null);
  const [destination, setDestination] = useState<Address | null>(null);
  const [suggestions, setSuggestions] = useState<Address[]>([]);
  const [searchTarget, setSearchTarget] = useState<AddressTarget>('pickup');
  const [carClasses, setCarClasses] = useState<CarClass[]>([]);
  const [selectedCarClassId, setSelectedCarClassId] = useState<string | null>(null);
  const [estimate, setEstimate] = useState<RouteEstimate | null>(null);
  const [paymentType, setPaymentType] = useState<PaymentType>('cash');
  const [comment, setComment] = useState('');
  const [createdOrder, setCreatedOrder] = useState<CreatedOrder | null>(null);
  const [isLoadingClasses, setIsLoadingClasses] = useState(true);
  const [isSearching, setIsSearching] = useState(false);
  const [isEstimating, setIsEstimating] = useState(false);
  const [isCreating, setIsCreating] = useState(false);
  const [isLocatingPickup, setIsLocatingPickup] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!session) return;
    void (async () => {
      try {
        const classes = await withAccessToken(getCarClasses);
        setCarClasses(classes);
        setSelectedCarClassId(classes[0]?.id ?? null);
      } catch (cause) {
        setError(cause instanceof BookingApiError ? cause.message : 'Не удалось загрузить классы автомобиля.');
      } finally {
        setIsLoadingClasses(false);
      }
    })();
  }, [session, withAccessToken]);

  if (!session) return null;

  async function handleSearch(target: AddressTarget) {
    if (!session) return;
    const query = target === 'pickup' ? pickupQuery.trim() : destinationQuery.trim();
    setSearchTarget(target);
    setSuggestions([]);
    setEstimate(null);
    if (query.length < 3) {
      setError('Введите не менее трёх символов адреса.');
      return;
    }
    setError(null);
    setIsSearching(true);
    try {
      const results = await withAccessToken((accessToken) => searchAddresses(accessToken, query, location));
      setSuggestions(results);
      if (results.length === 0) setError('Адреса не найдены. Уточните запрос.');
    } catch (cause) {
      setError(cause instanceof BookingApiError ? cause.message : 'Не удалось найти адрес.');
    } finally {
      setIsSearching(false);
    }
  }

  function selectAddress(address: Address) {
    if (searchTarget === 'pickup') {
      setPickup(address);
      setPickupQuery(address.address);
    } else {
      setDestination(address);
      setDestinationQuery(address.address);
    }
    setSuggestions([]);
    setEstimate(null);
  }

  async function handleUseCurrentLocation() {
    setError(null);
    setIsLocatingPickup(true);
    try {
      const location = await getCurrentAddress();
      const address: Address = {
        id: `location:${location.latitude}:${location.longitude}`,
        address: location.address,
        cityId: '',
        latitude: location.latitude,
        longitude: location.longitude,
      };
      setPickup(address);
      setPickupQuery(address.address);
      setSuggestions([]);
      setEstimate(null);
    } catch (cause) {
      setError(cause instanceof LocationError ? cause.message : 'Не удалось определить адрес по координатам.');
    } finally {
      setIsLocatingPickup(false);
    }
  }

  async function handleEstimate() {
    if (!session || !pickup || !destination || !selectedCarClassId) return;
    setError(null);
    setIsEstimating(true);
    try {
      setEstimate(await withAccessToken((accessToken) => estimateRoute(accessToken, pickup, destination, selectedCarClassId)));
    } catch (cause) {
      setError(cause instanceof BookingApiError ? cause.message : 'Не удалось рассчитать поездку.');
    } finally {
      setIsEstimating(false);
    }
  }

  async function handleCreateOrder() {
    if (!session || !pickup || !destination || !selectedCarClassId || !estimate) return;
    setError(null);
    setIsCreating(true);
    try {
      setCreatedOrder(await withAccessToken((accessToken) => createOrder(accessToken, { pickup, destination, carClassId: selectedCarClassId, paymentType, comment })));
    } catch (cause) {
      setError(cause instanceof BookingApiError ? cause.message : 'Не удалось создать заказ.');
    } finally {
      setIsCreating(false);
    }
  }

  const canEstimate = pickup !== null && destination !== null && selectedCarClassId !== null;
  return <SafeAreaView style={styles.safeArea}><ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
    <Pressable onPress={() => router.back()} hitSlop={12}><Text style={styles.back}>‹ Назад</Text></Pressable>
    <Text style={styles.title}>Куда поедем?</Text>
    <Text style={styles.subtitle}>Выберите точки маршрута и класс автомобиля.</Text>

    <AddressField label="Откуда" value={pickupQuery} selected={pickup} onChangeText={(value) => { setPickupQuery(value); setPickup(null); setEstimate(null); }} onSearch={() => void handleSearch('pickup')} loading={isSearching && searchTarget === 'pickup'} onUseCurrentLocation={() => void handleUseCurrentLocation()} isLocating={isLocatingPickup} />
    <AddressField label="Куда" value={destinationQuery} selected={destination} onChangeText={(value) => { setDestinationQuery(value); setDestination(null); setEstimate(null); }} onSearch={() => void handleSearch('destination')} loading={isSearching && searchTarget === 'destination'} />

    {suggestions.length > 0 ? <View style={styles.suggestions}>{suggestions.map((item) => <Pressable key={item.id} style={({ pressed }) => [styles.suggestion, pressed && styles.pressed]} onPress={() => selectAddress(item)}><Text style={styles.suggestionText}>{item.address}</Text></Pressable>)}</View> : null}

    <Text style={styles.sectionTitle}>Класс автомобиля</Text>
    {isLoadingClasses ? <ActivityIndicator style={styles.loader} /> : <View style={styles.classes}>{carClasses.map((item) => <Pressable key={item.id} onPress={() => { setSelectedCarClassId(item.id); setEstimate(null); }} style={({ pressed }) => [styles.classCard, selectedCarClassId === item.id && styles.classCardSelected, pressed && styles.pressed]}><Text style={styles.className}>{item.name}</Text>{item.description ? <Text style={styles.classDescription}>{item.description}</Text> : null}{item.basePrice !== null ? <Text style={styles.classPrice}>от {formatPrice(item.basePrice, item.currency)}</Text> : null}</Pressable>)}</View>}

    {error ? <Text style={styles.error}>{error}</Text> : null}
    {estimate ? <View style={styles.estimate}><Text style={styles.estimateTitle}>{estimate.carClassName || 'Поездка'}</Text>{estimate.price !== null ? <Text style={styles.estimatePrice}>{formatPrice(estimate.price, estimate.currency)}</Text> : null}<Text style={styles.estimateDetails}>{estimate.distanceKm !== null ? `${estimate.distanceKm.toFixed(1)} км` : ''}{estimate.distanceKm !== null && estimate.durationMin !== null ? ' · ' : ''}{estimate.durationMin !== null ? `≈ ${Math.round(estimate.durationMin)} мин` : ''}</Text></View> : null}
    <Pressable disabled={!canEstimate || isEstimating} onPress={() => void handleEstimate()} style={({ pressed }) => [styles.primaryButton, (!canEstimate || pressed || isEstimating) && styles.buttonDisabled]}>{isEstimating ? <ActivityIndicator color="#ffffff" /> : <Text style={styles.buttonText}>Рассчитать поездку</Text>}</Pressable>
    {estimate && !createdOrder ? <View style={styles.orderForm}><Text style={styles.sectionTitle}>Оплата</Text><View style={styles.payments}>{(['cash', 'card', 'corporate'] as const).map((item) => <Pressable key={item} onPress={() => setPaymentType(item)} style={[styles.payment, paymentType === item && styles.paymentSelected]}><Text style={[styles.paymentText, paymentType === item && styles.paymentTextSelected]}>{item === 'cash' ? 'Наличные' : item === 'card' ? 'Карта' : 'Корпоративная'}</Text></Pressable>)}</View><Text style={styles.label}>Комментарий водителю</Text><TextInput value={comment} onChangeText={setComment} style={styles.commentInput} placeholder="Например, подъезд со двора" multiline maxLength={500} /><Pressable disabled={isCreating} onPress={() => void handleCreateOrder()} style={({ pressed }) => [styles.createButton, (pressed || isCreating) && styles.buttonDisabled]}>{isCreating ? <ActivityIndicator color="#ffffff" /> : <Text style={styles.buttonText}>Подтвердить заказ</Text>}</Pressable></View> : null}
    {createdOrder ? <View style={styles.created}><Text style={styles.createdTitle}>Заказ создан</Text><Text style={styles.createdText}>Ищем водителя для заказа №{createdOrder.id.slice(0, 8)}.</Text><Pressable onPress={() => router.replace('./order')} style={styles.createdButton}><Text style={styles.createdButtonText}>Открыть текущий заказ</Text></Pressable></View> : null}
    {!estimate ? <Text style={styles.note}>Расчёт не создаёт заказ.</Text> : null}
  </ScrollView></SafeAreaView>;
}

function AddressField({ label, value, selected, onChangeText, onSearch, loading, onUseCurrentLocation, isLocating }: { label: string; value: string; selected: Address | null; onChangeText: (value: string) => void; onSearch: () => void; loading: boolean; onUseCurrentLocation?: () => void; isLocating?: boolean }) {
  return <View style={styles.fieldGroup}><Text style={styles.label}>{label}</Text><View style={styles.inputRow}><TextInput value={value} onChangeText={onChangeText} placeholder="Введите адрес" style={styles.input} returnKeyType="search" onSubmitEditing={onSearch} /><Pressable style={styles.searchButton} onPress={onSearch} disabled={loading}>{loading ? <ActivityIndicator /> : <Text style={styles.searchText}>Найти</Text>}</Pressable></View>{onUseCurrentLocation ? <Pressable onPress={onUseCurrentLocation} disabled={isLocating} style={({ pressed }) => [styles.locationButton, (pressed || isLocating) && styles.pressed]}>{isLocating ? <ActivityIndicator size="small" /> : <Text style={styles.locationButtonText}>Определить по моим координатам</Text>}</Pressable> : null}{selected ? <Text style={styles.selected}>Адрес выбран</Text> : null}</View>;
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: '#ffffff' }, content: { padding: 24, paddingBottom: 40 }, back: { color: '#1d4ed8', fontSize: 16, marginBottom: 22 }, title: { color: '#111111', fontSize: 30, fontWeight: '700' }, subtitle: { color: '#666666', fontSize: 16, lineHeight: 22, marginTop: 8 }, fieldGroup: { marginTop: 24 }, label: { color: '#111111', fontSize: 16, fontWeight: '600', marginBottom: 8 }, inputRow: { flexDirection: 'row', gap: 8 }, input: { borderColor: '#d4d4d4', borderRadius: 12, borderWidth: 1, color: '#111111', flex: 1, fontSize: 16, height: 52, paddingHorizontal: 14 }, searchButton: { alignItems: 'center', backgroundColor: '#e5e7eb', borderRadius: 12, justifyContent: 'center', minWidth: 74, paddingHorizontal: 10 }, searchText: { color: '#111111', fontWeight: '600' }, locationButton: { alignSelf: 'flex-start', marginTop: 10, paddingVertical: 6 }, locationButtonText: { color: '#1d4ed8', fontWeight: '600' }, selected: { color: '#15803d', marginTop: 7 }, suggestions: { borderColor: '#e5e7eb', borderRadius: 12, borderWidth: 1, marginTop: 14, overflow: 'hidden' }, suggestion: { borderBottomColor: '#e5e7eb', borderBottomWidth: 1, padding: 14 }, suggestionText: { color: '#111111', lineHeight: 21 }, sectionTitle: { color: '#111111', fontSize: 20, fontWeight: '700', marginTop: 30 }, loader: { marginTop: 20 }, classes: { gap: 10, marginTop: 14 }, classCard: { borderColor: '#d4d4d4', borderRadius: 14, borderWidth: 1, padding: 16 }, classCardSelected: { borderColor: '#111111', borderWidth: 2 }, className: { color: '#111111', fontSize: 17, fontWeight: '700' }, classDescription: { color: '#666666', lineHeight: 20, marginTop: 4 }, classPrice: { color: '#111111', fontWeight: '600', marginTop: 8 }, error: { color: '#b42318', lineHeight: 20, marginTop: 18 }, estimate: { backgroundColor: '#f3f4f6', borderRadius: 16, marginTop: 20, padding: 18 }, estimateTitle: { color: '#111111', fontSize: 17, fontWeight: '600' }, estimatePrice: { color: '#111111', fontSize: 28, fontWeight: '700', marginTop: 6 }, estimateDetails: { color: '#666666', marginTop: 6 }, primaryButton: { alignItems: 'center', backgroundColor: '#111111', borderRadius: 12, height: 54, justifyContent: 'center', marginTop: 22 }, buttonDisabled: { opacity: 0.45 }, buttonText: { color: '#ffffff', fontSize: 16, fontWeight: '700' }, orderForm: { marginTop: 4 }, payments: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 12, marginBottom: 20 }, payment: { borderColor: '#d4d4d4', borderRadius: 20, borderWidth: 1, paddingHorizontal: 13, paddingVertical: 9 }, paymentSelected: { backgroundColor: '#111111', borderColor: '#111111' }, paymentText: { color: '#111111', fontWeight: '600' }, paymentTextSelected: { color: '#ffffff' }, commentInput: { borderColor: '#d4d4d4', borderRadius: 12, borderWidth: 1, color: '#111111', fontSize: 16, minHeight: 80, padding: 14, textAlignVertical: 'top' }, createButton: { alignItems: 'center', backgroundColor: '#15803d', borderRadius: 12, height: 54, justifyContent: 'center', marginTop: 18 }, created: { backgroundColor: '#ecfdf3', borderColor: '#86efac', borderRadius: 16, borderWidth: 1, marginTop: 22, padding: 18 }, createdTitle: { color: '#166534', fontSize: 18, fontWeight: '700' }, createdText: { color: '#166534', lineHeight: 21, marginTop: 6 }, createdButton: { alignItems: 'center', backgroundColor: '#166534', borderRadius: 10, height: 44, justifyContent: 'center', marginTop: 14 }, createdButtonText: { color: '#ffffff', fontWeight: '700' }, note: { color: '#666666', fontSize: 13, lineHeight: 18, marginTop: 12, textAlign: 'center' }, pressed: { opacity: 0.72 },
});
