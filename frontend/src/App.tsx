import { useEffect, useState } from 'react';

type ApiStatus = 'sprawdzam…' | 'ok' | 'błąd' | 'brak VITE_API_URL';
const API_URL: string = import.meta.env.VITE_API_URL ?? '';

export function App() {
  const [status, setStatus] = useState<ApiStatus>(API_URL ? 'sprawdzam…' : 'brak VITE_API_URL');

  useEffect(() => {
    if (!API_URL) return;
    fetch(`${API_URL}/health`)
      .then((response) => setStatus(response.ok ? 'ok' : 'błąd'))
      .catch(() => setStatus('błąd'));
  }, []);

  return (
    <main style={{ fontFamily: 'system-ui, sans-serif', padding: 48, textAlign: 'center' }}>
      <h1>LearningTracker</h1>
      <p>API: {status}</p>
    </main>
  );
}
