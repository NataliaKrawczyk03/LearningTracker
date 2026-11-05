import { getHealth } from './api.js'

const app = document.querySelector('#app')

app.innerHTML = `
  <h1>LearningTracker</h1>
  <p>hello world</p>
  <p id="status">Sprawdzam API...</p>
`

const status = document.querySelector('#status')

getHealth()
  .then((data) => {
    status.textContent = `API: ${data.status}`
  })
  .catch(() => {
    status.textContent = 'API: niedostępne'
  })
