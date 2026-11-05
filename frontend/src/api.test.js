import { describe, it, expect, vi } from 'vitest'
import { getHealth } from './api.js'

describe('getHealth', () => {
  it('zwraca status z API', async () => {
    globalThis.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ status: 'ok' }),
    })
    expect(await getHealth()).toEqual({ status: 'ok' })
  })

  it('rzuca błąd gdy API odpowie błędem', async () => {
    globalThis.fetch = vi.fn().mockResolvedValue({ ok: false, status: 500 })
    await expect(getHealth()).rejects.toThrow('500')
  })
})
