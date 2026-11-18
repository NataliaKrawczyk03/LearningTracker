import { getHealth } from './api'

const app = document.querySelector<HTMLDivElement>('#app')
if (!app) {
  throw new Error('Missing #app element in index.html')
}

app.innerHTML = `
  <h1>LearningTracker</h1>
  <p>hello world</p>
  <p id="status">Sprawdzam API...</p>
`

const status = app.querySelector<HTMLParagraphElement>('#status')!

getHealth()
  .then((data) => {
    status.textContent = `API: ${data.status}`
  })
  .catch(() => {
    status.textContent = 'API: niedostępne'
  })
