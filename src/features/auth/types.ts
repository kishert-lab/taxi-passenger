export type Passenger = {
  id: string;
  phone: string;
  name: string;
  email: string;
  avatarUrl: string;
};

export type AuthTokens = {
  accessToken: string;
  refreshToken: string;
  expiresAt: string;
};

export type AuthSession = {
  passenger: Passenger;
  tokens: AuthTokens;
};
