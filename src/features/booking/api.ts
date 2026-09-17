import { environment } from '@/shared/config/environment';
import type { components, paths } from '@/api/generated/openapi';
import type { CurrentLocation } from '@/features/location/location-service';

type AddressSearchResponse = components['schemas']['internal_transport_http_handler.PassengerAddressSearchResponse'];
type AddressSearchResult = components['schemas']['internal_transport_http_handler.PassengerAddressSearchResultResponse'];
type CarClassesResponse = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.PassengerCarClassesResponse'];
type CarClassResponse = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.PassengerCarClassResponse'];
type EstimatePayload = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.OrderEstimateRequest'];
type EstimateResponse = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.OrderEstimateResponse'];
type CreateOrderPayload = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.PassengerCreateOrderRequest'];
type PassengerOrderResponse = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.PassengerOrderResponse'];
type OrderHistoryResponse = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.OrderHistoryResponse'];
type CancelOrderPayload = components['schemas']['github_com_kishert-lab_taxi-platform_internal_dto.CancelOrderRequest'];
type ApiErrorResponse = components['schemas']['github_com_kishert-lab_taxi-platform_pkg_response.Error'];
type AddressSearchQuery = NonNullable<paths['/passenger/address/search']['get']>['parameters']['query'];

const endpoints = {
  addressSearch: '/passenger/address/search',
  carClasses: '/passenger/car-classes',
  estimate: '/passenger/orders/estimate',
  orders: '/passenger/orders',
  currentOrder: '/passenger/orders/current',
  orderHistory: '/passenger/orders/history',
} as const satisfies Record<string, keyof paths>;

export type Address = {
  id: string;
  address: string;
  cityId: string;
  latitude: number;
  longitude: number;
};

export type CarClass = {
  id: string;
  name: string;
  description: string;
  basePrice: number | null;
  currency: string;
};

export type RouteEstimate = {
  price: number | null;
  currency: string;
  distanceKm: number | null;
  durationMin: number | null;
  carClassName: string;
};

export type PaymentType = CreateOrderPayload['payment_type'];

export type CreatedOrder = {
  id: string;
  status: string;
  carClassName: string;
};

export type PassengerOrder = {
  id: string;
  status: string;
  pickupAddress: string;
  destinationAddress: string;
  carClassName: string;
  price: number | null;
  currency: string;
  etaSeconds: number | null;
  driver: { name: string; phone: string; rating: number | null } | null;
  car: { title: string; plateNumber: string } | null;
  allowedActions: string[];
};

export class BookingApiError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
  }
}

async function request<T>(accessToken: string, path: string, init: RequestInit = {}): Promise<T> {
  let response: Response;
  try {
    response = await fetch(`${environment.apiUrl}/api/v1${path}`, {
      ...init,
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
        ...init.headers,
      },
    });
  } catch {
    throw new BookingApiError('Не удалось подключиться к серверу. Проверьте соединение.', 0);
  }

  const body = (await response.json().catch(() => null)) as { data?: T; error?: ApiErrorResponse['error'] } | null;
  if (!response.ok) {
    throw new BookingApiError(body?.error?.message ?? 'Сервер вернул ошибку.', response.status);
  }
  if (!body || body.data === undefined) {
    throw new BookingApiError('Сервер вернул некорректный ответ.', response.status);
  }
  return body.data;
}

function mapAddress(result: AddressSearchResult): Address | null {
  const latitude = result.coordinates?.latitude;
  const longitude = result.coordinates?.longitude;
  const address = result.address ?? result.name;
  if (!address || latitude === undefined || longitude === undefined) return null;
  return {
    id: result.id ?? result.external_place_id ?? address,
    address,
    cityId: result.city_id ?? '',
    latitude,
    longitude,
  };
}

function mapCarClass(carClass: CarClassResponse): CarClass | null {
  if (!carClass.id || !carClass.name) return null;
  return {
    id: carClass.id,
    name: carClass.name,
    description: carClass.description ?? '',
    basePrice: carClass.minimum_price ?? carClass.base_price ?? null,
    currency: carClass.currency ?? 'RUB',
  };
}

export async function searchAddresses(accessToken: string, query: string, location: CurrentLocation | null): Promise<Address[]> {
  const queryParameters: AddressSearchQuery = {
    q: query,
    limit: 5,
    ...(location ? { lat: location.latitude, lon: location.longitude } : {}),
  };
  const params = new URLSearchParams(Object.entries(queryParameters).filter(([, value]) => value !== undefined).map(([key, value]) => [key, String(value)]));
  const response = await request<AddressSearchResponse>(accessToken, `${endpoints.addressSearch}?${params.toString()}`);
  return (response.results ?? []).map(mapAddress).filter((item): item is Address => item !== null);
}

export async function getCarClasses(accessToken: string): Promise<CarClass[]> {
  const response = await request<CarClassesResponse>(accessToken, endpoints.carClasses);
  return (response.items ?? []).map(mapCarClass).filter((item): item is CarClass => item !== null);
}

export async function estimateRoute(accessToken: string, pickup: Address, destination: Address, carClassId: string): Promise<RouteEstimate> {
  const payload: EstimatePayload = {
    city_id: pickup.cityId || destination.cityId || undefined,
    car_class_id: carClassId,
    pickup_location: { latitude: pickup.latitude, longitude: pickup.longitude },
    destination_location: { latitude: destination.latitude, longitude: destination.longitude },
  };
  const response = await request<EstimateResponse>(accessToken, endpoints.estimate, {
    method: 'POST',
    body: JSON.stringify(payload),
  });
  return {
    price: response.price ?? null,
    currency: response.currency ?? 'RUB',
    distanceKm: response.distance_km ?? null,
    durationMin: response.duration_min ?? null,
    carClassName: response.car_class_name ?? response.car_class ?? '',
  };
}

export async function createOrder(accessToken: string, input: {
  pickup: Address;
  destination: Address;
  carClassId: string;
  paymentType: PaymentType;
  comment: string;
}): Promise<CreatedOrder> {
  const payload: CreateOrderPayload = {
    city_id: input.pickup.cityId || input.destination.cityId || undefined,
    car_class_id: input.carClassId,
    payment_type: input.paymentType,
    pickup_address: input.pickup.address,
    pickup_location: { latitude: input.pickup.latitude, longitude: input.pickup.longitude },
    destination_address: input.destination.address,
    destination_location: { latitude: input.destination.latitude, longitude: input.destination.longitude },
    ...(input.comment.trim() ? { comment: input.comment.trim() } : {}),
  };
  const response = await request<PassengerOrderResponse>(accessToken, endpoints.orders, {
    method: 'POST',
    body: JSON.stringify(payload),
  });
  if (!response.order_id) {
    throw new BookingApiError('Сервер не вернул идентификатор заказа.', 201);
  }
  return {
    id: response.order_id,
    status: response.status ?? 'searching',
    carClassName: response.car_class_name ?? response.car_class ?? '',
  };
}

function mapPassengerOrder(response: PassengerOrderResponse): PassengerOrder | null {
  if (!response.order_id) return null;
  const carTitle = [response.car?.brand, response.car?.model].filter(Boolean).join(' ');
  return {
    id: response.order_id,
    status: response.status ?? 'unknown',
    pickupAddress: response.pickup_point?.address ?? '',
    destinationAddress: response.destination_point?.address ?? '',
    carClassName: response.car_class_name ?? response.car_class ?? '',
    price: response.price?.amount ?? null,
    currency: response.price?.currency ?? 'RUB',
    etaSeconds: response.eta_seconds ?? null,
    driver: response.driver ? { name: response.driver.name ?? 'Водитель', phone: response.driver.phone ?? '', rating: response.driver.rating ?? null } : null,
    car: response.car ? { title: carTitle || 'Автомобиль', plateNumber: response.car.plate_number ?? '' } : null,
    allowedActions: response.allowed_actions ?? [],
  };
}

export async function getCurrentOrder(accessToken: string): Promise<PassengerOrder | null> {
  try {
    const response = await request<PassengerOrderResponse>(accessToken, endpoints.currentOrder);
    return mapPassengerOrder(response);
  } catch (error) {
    if (error instanceof BookingApiError && error.status === 404) return null;
    throw error;
  }
}

export async function getOrderHistory(accessToken: string): Promise<PassengerOrder[]> {
  const response = await request<OrderHistoryResponse>(accessToken, endpoints.orderHistory);
  return (response.orders ?? []).map(mapPassengerOrder).filter((order): order is PassengerOrder => order !== null);
}

export async function cancelOrder(accessToken: string, orderId: string, reason: string): Promise<PassengerOrder> {
  const payload: CancelOrderPayload = { reason };
  const response = await request<PassengerOrderResponse>(accessToken, `/passenger/orders/${encodeURIComponent(orderId)}/cancel`, {
    method: 'POST',
    body: JSON.stringify(payload),
  });
  const order = mapPassengerOrder(response);
  if (!order) throw new BookingApiError('Сервер не вернул данные заказа.', 200);
  return order;
}
