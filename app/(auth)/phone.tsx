import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import { ActivityIndicator, KeyboardAvoidingView, Modal, Platform, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { ApiError, getLegalDocument, type LegalDocument } from '@/features/auth/api';
import { useAuth } from '@/features/auth/auth-provider';
import { normalizeRussianPhone } from '@/features/auth/phone';

export default function PhoneScreen() {
  const { requestCode } = useAuth();
  const [phone, setPhone] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [consentAccepted, setConsentAccepted] = useState(false);
  const [termsAccepted, setTermsAccepted] = useState(false);
  const [documents, setDocuments] = useState<{ consent: LegalDocument; terms: LegalDocument } | null>(null);
  const [documentToShow, setDocumentToShow] = useState<LegalDocument | null>(null);

  useEffect(() => {
    void Promise.all([getLegalDocument('consent'), getLegalDocument('terms')])
      .then(([consent, terms]) => setDocuments({ consent, terms }))
      .catch(() => setError('Не удалось загрузить документы для согласия.'));
  }, []);

  async function handleContinue() {
    const normalizedPhone = normalizeRussianPhone(phone);
    if (!normalizedPhone) {
      setError('Введите номер в формате 8 999 123-45-67 или +7 999 123-45-67.');
      return;
    }
    if (!documents) {
      setError('Документы для согласия пока недоступны. Повторите попытку позже.');
      return;
    }
    if (!consentAccepted || !termsAccepted) {
      setError('Для продолжения подтвердите согласие на обработку персональных данных и принятие условий сервиса.');
      return;
    }
    setError(null);
    setIsSubmitting(true);
    try {
      await requestCode(normalizedPhone);
      router.push({ pathname: '/code', params: { phone: normalizedPhone } });
    } catch (requestError) {
      setError(requestError instanceof ApiError ? requestError.message : 'Не удалось отправить код.');
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <View style={styles.content}>
          <Text style={styles.title}>Вход или регистрация</Text>
          <Text style={styles.description}>Введите номер телефона. Мы отправим SMS-код для входа или создания аккаунта.</Text>
          <TextInput value={phone} onChangeText={setPhone} placeholder="8 999 123-45-67" keyboardType="phone-pad" autoComplete="tel" textContentType="telephoneNumber" editable={!isSubmitting} style={styles.input} accessibilityLabel="Номер телефона" />
          {documents ? <>
            <ConsentRow value={consentAccepted} onChange={setConsentAccepted} label="Даю согласие на обработку персональных данных (152‑ФЗ)" onOpen={() => setDocumentToShow(documents.consent)} />
            <ConsentRow value={termsAccepted} onChange={setTermsAccepted} label="Принимаю пользовательское соглашение" onOpen={() => setDocumentToShow(documents.terms)} />
          </> : <View style={styles.documentsLoading}><ActivityIndicator /><Text style={styles.documentsLoadingText}>Загружаем документы…</Text></View>}
          {error ? <Text style={styles.error}>{error}</Text> : null}
          <Pressable style={({ pressed }) => [styles.button, (pressed || isSubmitting) && styles.buttonPressed]} onPress={() => void handleContinue()} disabled={isSubmitting}>
            {isSubmitting ? <ActivityIndicator color="#ffffff" /> : <Text style={styles.buttonText}>Получить код</Text>}
          </Pressable>
        </View>
      </KeyboardAvoidingView>
      <Modal visible={Boolean(documentToShow)} animationType="slide" onRequestClose={() => setDocumentToShow(null)}>
        <SafeAreaView style={styles.documentSafeArea}>
          <View style={styles.documentHeader}><Text style={styles.documentTitle}>{documentToShow?.title}</Text><Pressable onPress={() => setDocumentToShow(null)}><Text style={styles.closeText}>Закрыть</Text></Pressable></View>
          <Text style={styles.documentVersion}>Версия {documentToShow?.version}</Text>
          <ScrollView contentContainerStyle={styles.documentContent}><Text style={styles.documentText}>{documentToShow?.content}</Text></ScrollView>
        </SafeAreaView>
      </Modal>
    </SafeAreaView>
  );
}

function ConsentRow({ value, onChange, label, onOpen }: { value: boolean; onChange: (value: boolean) => void; label: string; onOpen: () => void }) {
  return <View style={styles.consentRow}><Pressable accessibilityRole="checkbox" accessibilityState={{ checked: value }} onPress={() => onChange(!value)} style={[styles.checkbox, value && styles.checkboxChecked]}><Text style={styles.checkboxMark}>{value ? '✓' : ''}</Text></Pressable><View style={styles.consentContent}><Text style={styles.consentLabel}>{label}</Text><Pressable onPress={onOpen}><Text style={styles.documentLink}>Открыть документ</Text></Pressable></View></View>;
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: '#ffffff' }, container: { flex: 1 }, content: { flex: 1, justifyContent: 'center', paddingHorizontal: 24 },
  title: { fontSize: 30, fontWeight: '700', color: '#111111', marginBottom: 12 }, description: { fontSize: 16, color: '#666666', lineHeight: 22, marginBottom: 24 },
  input: { height: 56, borderWidth: 1, borderColor: '#dddddd', borderRadius: 12, paddingHorizontal: 16, fontSize: 18, color: '#111111', marginBottom: 12 },
  error: { color: '#b42318', lineHeight: 20, marginBottom: 12 }, button: { height: 56, borderRadius: 12, backgroundColor: '#111111', alignItems: 'center', justifyContent: 'center' }, buttonPressed: { opacity: 0.75 }, buttonText: { color: '#ffffff', fontSize: 16, fontWeight: '600' },
  consentRow: { flexDirection: 'row', marginBottom: 16 }, checkbox: { width: 24, height: 24, borderRadius: 6, borderWidth: 1, borderColor: '#767676', alignItems: 'center', justifyContent: 'center', marginRight: 12 }, checkboxChecked: { backgroundColor: '#111111', borderColor: '#111111' }, checkboxMark: { color: '#ffffff', fontSize: 16, fontWeight: '700' }, consentContent: { flex: 1 }, consentLabel: { color: '#222222', lineHeight: 20 }, documentLink: { color: '#1d4ed8', marginTop: 4 }, documentsLoading: { flexDirection: 'row', alignItems: 'center', marginBottom: 16 }, documentsLoadingText: { color: '#666666', marginLeft: 8 },
  documentSafeArea: { flex: 1, backgroundColor: '#ffffff' }, documentHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', padding: 20, paddingBottom: 8 }, documentTitle: { flex: 1, fontSize: 20, fontWeight: '700', marginRight: 16 }, closeText: { color: '#1d4ed8', fontSize: 16 }, documentVersion: { color: '#666666', paddingHorizontal: 20, paddingBottom: 12 }, documentContent: { padding: 20, paddingTop: 8 }, documentText: { color: '#222222', fontSize: 16, lineHeight: 23 },
});
