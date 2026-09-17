import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react';

import { confirmCode, logout, refreshTokens, requestCode } from './api';
import { clearSession, readSession, saveSession } from './storage';
import type { AuthSession } from './types';

type AuthContextValue = {
  isBootstrapping: boolean;
  session: AuthSession | null;
  requestCode: (phone: string) => Promise<void>;
  confirmCode: (phone: string, code: string, name: string) => Promise<void>;
  withAccessToken: <T>(operation: (accessToken: string) => Promise<T>) => Promise<T>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

function parseStoredSession(value: string): AuthSession | null {
  try {
    const session = JSON.parse(value) as AuthSession;
    return session.tokens.accessToken && session.tokens.refreshToken && session.passenger.id ? session : null;
  } catch {
    return null;
  }
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [isBootstrapping, setIsBootstrapping] = useState(true);
  const [session, setSession] = useState<AuthSession | null>(null);

  useEffect(() => {
    void (async () => {
      try {
        const rawSession = await readSession();
        const storedSession = rawSession ? parseStoredSession(rawSession) : null;
        if (!storedSession) {
          if (rawSession) await clearSession();
          return;
        }

        if (new Date(storedSession.tokens.expiresAt).getTime() > Date.now() + 30_000) {
          setSession(storedSession);
          return;
        }

        const tokens = await refreshTokens(storedSession.tokens.refreshToken);
        const refreshedSession = { ...storedSession, tokens };
        await saveSession(refreshedSession);
        setSession(refreshedSession);
      } catch {
        await clearSession().catch(() => undefined);
      } finally {
        setIsBootstrapping(false);
      }
    })();
  }, []);

  const sendCode = useCallback(async (phone: string) => { await requestCode(phone); }, []);
  const verifyCode = useCallback(async (phone: string, code: string, name: string) => {
    const nextSession = await confirmCode(phone, code, name);
    await saveSession(nextSession);
    setSession(nextSession);
  }, []);
  const runWithAccessToken = useCallback(async <T,>(operation: (accessToken: string) => Promise<T>): Promise<T> => {
    if (!session) throw new Error('Пассажир не авторизован.');
    try {
      return await operation(session.tokens.accessToken);
    } catch (error) {
      const status = typeof error === 'object' && error !== null && 'status' in error ? error.status : undefined;
      if (status !== 401) throw error;
    }

    try {
      const tokens = await refreshTokens(session.tokens.refreshToken);
      const refreshedSession = { ...session, tokens };
      await saveSession(refreshedSession);
      setSession(refreshedSession);
      return await operation(tokens.accessToken);
    } catch (error) {
      await clearSession().catch(() => undefined);
      setSession(null);
      throw error;
    }
  }, [session]);
  const endSession = useCallback(async () => {
    if (session) {
      try {
        await logout(session.tokens.accessToken, session.tokens.refreshToken);
      } catch {
        // Clear local credentials even if the logout request cannot reach the server.
      }
    }
    await clearSession();
    setSession(null);
  }, [session]);

  const value = useMemo(() => ({ isBootstrapping, session, requestCode: sendCode, confirmCode: verifyCode, withAccessToken: runWithAccessToken, logout: endSession }), [endSession, isBootstrapping, runWithAccessToken, sendCode, session, verifyCode]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth must be used within AuthProvider.');
  return value;
}
