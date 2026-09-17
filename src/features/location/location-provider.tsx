import { createContext, useContext, useEffect, useMemo, useRef, useState } from 'react';

import { useAuth } from '@/features/auth/auth-provider';

import { getCurrentLocation, type CurrentLocation } from './location-service';

type LocationContextValue = {
  location: CurrentLocation | null;
};

const LocationContext = createContext<LocationContextValue | null>(null);

export function LocationProvider({ children }: { children: React.ReactNode }) {
  const { session } = useAuth();
  const [location, setLocation] = useState<CurrentLocation | null>(null);
  const hasRequestedPermission = useRef(false);

  useEffect(() => {
    const passengerId = session?.passenger.id;
    if (!passengerId) {
      setLocation(null);
      return;
    }
    if (hasRequestedPermission.current) return;

    hasRequestedPermission.current = true;
    void getCurrentLocation().then(setLocation).catch(() => setLocation(null));
  }, [session?.passenger.id]);

  const value = useMemo(() => ({ location }), [location]);
  return <LocationContext.Provider value={value}>{children}</LocationContext.Provider>;
}

export function useLocation(): LocationContextValue {
  const value = useContext(LocationContext);
  if (!value) throw new Error('useLocation must be used within LocationProvider.');
  return value;
}
