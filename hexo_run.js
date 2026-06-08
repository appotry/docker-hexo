const { exec } = require('child_process')
const port = process.env.HEXO_SERVER_PORT || 4000
exec(`hexo server -p ${port}`, (error, stdout, stderr) => {
  if (error) {
    console.error(`exec error: ${error}`)
    return
  }
  console.log(`stdout: ${stdout}`)
  console.log(`stderr: ${stderr}`)
})
