const apiUrl = process.env.EXPO_PUBLIC_API_URL;

if (!apiUrl) {
  throw new Error('EXPO_PUBLIC_API_URL is required. Copy .env.example to .env.');
}

const parsedApiUrl = new URL(apiUrl);

if (parsedApiUrl.protocol !== 'http:' && parsedApiUrl.protocol !== 'https:') {
  throw new Error('EXPO_PUBLIC_API_URL must use HTTP or HTTPS.');
}

export const environment = Object.freeze({ apiUrl });
