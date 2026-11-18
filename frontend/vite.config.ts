import { defineConfig } from 'vitest/config'

export default defineConfig({
  base: '/LearningTracker/',
  test: {
    environment: 'jsdom',
  },
})
