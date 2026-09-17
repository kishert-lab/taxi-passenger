import * as Location from 'expo-location';

export type CurrentLocation = {
  latitude: number;
  longitude: number;
  accuracy: number | null;
  capturedAt: Date;
};

export class LocationError extends Error {}

export async function getCurrentAddress(): Promise<CurrentLocation & { address: string }> {
  const location = await getCurrentLocation();
  try {
    const [place] = await Location.reverseGeocodeAsync({ latitude: location.latitude, longitude: location.longitude });
    const address = place ? [place.city, place.street, place.streetNumber].filter(Boolean).join(', ') : '';
    return { ...location, address: address || `${location.latitude.toFixed(5)}, ${location.longitude.toFixed(5)}` };
  } catch {
    return { ...location, address: `${location.latitude.toFixed(5)}, ${location.longitude.toFixed(5)}` };
  }
}

export async function getCurrentLocation(): Promise<CurrentLocation> {
  const servicesEnabled = await Location.hasServicesEnabledAsync();
  if (!servicesEnabled) {
    throw new LocationError('Включите геолокацию в настройках устройства.');
  }

  let permission = await Location.getForegroundPermissionsAsync();
  if (!permission.granted) {
    permission = await Location.requestForegroundPermissionsAsync();
  }
  if (!permission.granted) {
    throw new LocationError('Нет доступа к геолокации. Разрешите доступ в настройках приложения.');
  }

  try {
    const position = await Location.getCurrentPositionAsync({ accuracy: Location.Accuracy.Balanced });
    return {
      latitude: position.coords.latitude,
      longitude: position.coords.longitude,
      accuracy: position.coords.accuracy,
      capturedAt: new Date(position.timestamp),
    };
  } catch {
    throw new LocationError('Не удалось определить текущее местоположение.');
  }
}
