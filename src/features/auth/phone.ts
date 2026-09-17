export function normalizeRussianPhone(value: string): string | null {
  const digits = value.replace(/\D/g, '');
  const localNumber = digits.length === 11 && (digits.startsWith('7') || digits.startsWith('8'))
    ? digits.slice(1)
    : digits.length === 10
      ? digits
      : null;

  return localNumber ? `+7${localNumber}` : null;
}
