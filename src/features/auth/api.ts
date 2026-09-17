import { environment } from '@/shared/config/environment';
import type { components, paths } from '@/api/generated/openapi';

import type { AuthSession, AuthTokens, Passenger } from './types';

type ApiErrorResponse = components['schemas']['github_com_kishert-lab_taxi-platform_pkg_response.Error'];
type RequestCodePayload = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.PassengerAuthRequestCodeRequest'];
type RequestCodeResponse = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.PassengerAuthRequestCodeResponse'];
type ConfirmCodePayload = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.PassengerAuthConfirmCodeRequest'];
type TokenResponse = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.PassengerAuthTokenResponse'];
type RefreshPayload = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.RefreshTokenRequest'];
type LogoutPayload = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.LogoutRequest'];
type LogoutResponse = components['schemas']['internal_transport_http_handler.passengerLogoutResponse'];
type PassengerResponse = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.PassengerMeResponse'];
type LegalDocumentResponse = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.LegalDocumentResponse'];

const endpoints = {
  requestCode: '/passenger/auth/request-code',
  confirmCode: '/passenger/auth/confirm-code',
  refresh: '/passenger/auth/refresh',
  logout: '/passenger/auth/logout',
  consent: '/public/legal/consent',
  terms: '/public/legal/terms',
} as const satisfies Record<string, keyof paths>;

export type LegalDocument = {
  id: string;
  title: string;
  content: string;
  version: string;
  documentType: string;
};

export class ApiError extends Error {
  constructor(
    message: string,
    readonly status: number,
    readonly code?: string,
  ) {
    super(message);
  }
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  let response: Response;
  try {
    response = await fetch(`${environment.apiUrl}/api/v1${path}`, {
      ...init,
      headers: { Accept: 'application/json', 'Content-Type': 'application/json', ...init.headers },
    });
  } catch {
    throw new ApiError('Не удалось подключиться к серверу. Проверьте соединение.', 0);
  }

  const body = (await response.json().catch(() => null)) as { data?: T; error?: ApiErrorResponse['error'] } | null;
  if (!response.ok) {
    throw new ApiError(body?.error?.message ?? 'Сервер вернул ошибку.', response.status, body?.error?.code);
  }

  if (!body || body.data === undefined) {
    throw new ApiError('Сервер вернул некорректный ответ.', response.status);
  }
  return body.data;
}

function mapPassenger(passenger: PassengerResponse): Passenger {
  return {
    id: passenger.id ?? '',
    phone: passenger.phone ?? '',
    name: passenger.name ?? '',
    email: passenger.email ?? '',
    avatarUrl: passenger.avatar_url ?? '',
  };
}

function mapTokens(response: TokenResponse): AuthTokens {
  if (!response.access_token || !response.refresh_token || !response.expires_in) {
    throw new ApiError('Сервер не выдал пару токенов.', 200);
  }
  return {
    accessToken: response.access_token,
    refreshToken: response.refresh_token,
    expiresAt: new Date(Date.now() + response.expires_in * 1000).toISOString(),
  };
}

export function requestCode(phone: string): Promise<RequestCodeResponse> {
  const payload: RequestCodePayload = { phone };
  return request<RequestCodeResponse>(endpoints.requestCode, { method: 'POST', body: JSON.stringify(payload) });
}

export async function getLegalDocument(type: 'consent' | 'terms'): Promise<LegalDocument> {
  const response = await request<LegalDocumentResponse>(
    `${endpoints[type]}?language=ru`,
  );
  return {
    id: response.id ?? '',
    title: response.title ?? '',
    content: response.content ?? '',
    version: response.version ?? '',
    documentType: response.document_type ?? '',
  };
}

export async function confirmCode(phone: string, code: string, name: string): Promise<AuthSession> {
  const payload: ConfirmCodePayload = { phone, code, ...(name ? { name } : {}) };
  const response = await request<TokenResponse>(endpoints.confirmCode, {
    method: 'POST',
    body: JSON.stringify(payload),
  });
  if (!response.passenger) {
    throw new ApiError('Сервер не вернул данные пассажира.', 200);
  }
  return { tokens: mapTokens(response), passenger: mapPassenger(response.passenger) };
}

export async function refreshTokens(refreshToken: string): Promise<AuthTokens> {
  const payload: RefreshPayload = { refresh_token: refreshToken };
  const response = await request<TokenResponse>(endpoints.refresh, {
    method: 'POST',
    body: JSON.stringify(payload),
  });
  return mapTokens(response);
}

export function logout(accessToken: string, refreshToken: string): Promise<LogoutResponse> {
  const payload: LogoutPayload = { refresh_token: refreshToken };
  return request<LogoutResponse>(endpoints.logout, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}` },
    body: JSON.stringify(payload),
  });
}
