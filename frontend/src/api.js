// Adres API jest wstrzykiwany przy buildzie ze zmiennej VITE_API_URL.
export const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

export async function getHealth() {
  const response = await fetch(`${API_URL}/health`)
  if (!response.ok) {
    throw new Error(`API zwróciło status ${response.status}`)
  }
  return response.json()
}
