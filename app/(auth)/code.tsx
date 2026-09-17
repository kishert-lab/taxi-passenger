import { router, useLocalSearchParams } from 'expo-router';
import { useState } from 'react';
import { ActivityIndicator, KeyboardAvoidingView, Platform, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { ApiError } from '@/features/auth/api';
import { useAuth } from '@/features/auth/auth-provider';

export default function CodeScreen() {
  const { phone } = useLocalSearchParams<{ phone: string }>();
  const { confirmCode, requestCode } = useAuth();
  const [code, setCode] = useState('');
  const [name, setName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleConfirm() {
    if (!phone) return router.replace('/phone');
    if (!/^\d{4,6}$/.test(code)) return setError('Введите код из 4–6 цифр.');
    setError(null); setIsSubmitting(true);
    try {
      await confirmCode(phone, code, name.trim());
      router.replace('/home');
    } catch (requestError) {
      setError(requestError instanceof ApiError ? requestError.message : 'Не удалось подтвердить код.');
    } finally { setIsSubmitting(false); }
  }

  async function handleResend() {
    if (!phone) return;
    setError(null); setIsSubmitting(true);
    try { await requestCode(phone); } catch (requestError) {
      setError(requestError instanceof ApiError ? requestError.message : 'Не удалось отправить код повторно.');
    } finally { setIsSubmitting(false); }
  }

  return <SafeAreaView style={styles.safeArea}><KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}><View style={styles.content}>
    <Text style={styles.title}>Подтверждение номера</Text><Text style={styles.description}>Код отправлен на {phone}.</Text>
    <TextInput value={code} onChangeText={(value) => setCode(value.replace(/\D/g, '').slice(0, 6))} placeholder="SMS-код" keyboardType="number-pad" autoComplete="one-time-code" textContentType="oneTimeCode" editable={!isSubmitting} style={styles.input} accessibilityLabel="SMS-код" />
    <TextInput value={name} onChangeText={setName} placeholder="Ваше имя (для нового аккаунта)" autoComplete="name" editable={!isSubmitting} style={styles.input} accessibilityLabel="Имя" />
    {error ? <Text style={styles.error}>{error}</Text> : null}
    <Pressable style={({ pressed }) => [styles.button, (pressed || isSubmitting) && styles.buttonPressed]} onPress={() => void handleConfirm()} disabled={isSubmitting}>{isSubmitting ? <ActivityIndicator color="#ffffff" /> : <Text style={styles.buttonText}>Подтвердить</Text>}</Pressable>
    <Pressable style={styles.resendButton} onPress={() => void handleResend()} disabled={isSubmitting}><Text style={styles.resendText}>Отправить код ещё раз</Text></Pressable>
    <Pressable onPress={() => router.replace('/phone')} disabled={isSubmitting}><Text style={styles.changePhoneText}>Изменить номер</Text></Pressable>
  </View></KeyboardAvoidingView></SafeAreaView>;
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: '#ffffff' }, container: { flex: 1 }, content: { flex: 1, justifyContent: 'center', paddingHorizontal: 24 },
  title: { fontSize: 30, fontWeight: '700', color: '#111111', marginBottom: 12 }, description: { fontSize: 16, color: '#666666', lineHeight: 22, marginBottom: 24 },
  input: { height: 56, borderWidth: 1, borderColor: '#dddddd', borderRadius: 12, paddingHorizontal: 16, fontSize: 18, color: '#111111', marginBottom: 12 }, error: { color: '#b42318', lineHeight: 20, marginBottom: 12 },
  button: { height: 56, borderRadius: 12, backgroundColor: '#111111', alignItems: 'center', justifyContent: 'center' }, buttonPressed: { opacity: 0.75 }, buttonText: { color: '#ffffff', fontSize: 16, fontWeight: '600' },
  resendButton: { alignItems: 'center', paddingVertical: 20 }, resendText: { color: '#1d4ed8', fontSize: 16, fontWeight: '600' }, changePhoneText: { color: '#666666', textAlign: 'center', fontSize: 16 },
});
