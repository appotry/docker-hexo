const { spawn } = require('child_process')
const port = process.env.HEXO_SERVER_PORT || 4000
const child = spawn('hexo', ['server', '-p', String(port)], {
  stdio: 'inherit'
})
child.on('error', (error) => {
  console.error(`spawn error: ${error}`)
})
