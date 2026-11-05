import { defineConfig } from 'vite'

export default defineConfig({
  base: '/LearningTracker/',
  test: {
    environment: 'jsdom',
  },
})
