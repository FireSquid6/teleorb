export function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

export function isValidPassword(password: string): boolean {
  const specialCharacters = ["!", "@", "#", "$", "%", "^", "&", "*"];
  return (
    /[a-z]/.test(password) &&
    /[A-Z]/.test(password) &&
    /[0-9]/.test(password) &&
    password.length >= 8 &&
    specialCharacters.some((char) => password.includes(char))
  );
}
