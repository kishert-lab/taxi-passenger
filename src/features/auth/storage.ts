import * as SecureStore from 'expo-secure-store';

import type { AuthSession } from './types';

const sessionKey = 'passenger_auth_session';

export function readSession(): Promise<string | null> {
  return SecureStore.getItemAsync(sessionKey);
}

export function saveSession(session: AuthSession): Promise<void> {
  return SecureStore.setItemAsync(sessionKey, JSON.stringify(session));
}

export function clearSession(): Promise<void> {
  return SecureStore.deleteItemAsync(sessionKey);
}
