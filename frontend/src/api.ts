// Injected at build time from VITE_API_URL.
export const API_URL: string = import.meta.env.VITE_API_URL || 'http://localhost:8000'

export interface Health {
  status: string
}

export async function getHealth(): Promise<Health> {
  const response = await fetch(`${API_URL}/health`)
  if (!response.ok) {
    throw new Error(`API zwróciło status ${response.status}`)
  }
  return (await response.json()) as Health
}
