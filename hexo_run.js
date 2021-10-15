//run
const { exec } = require('child_process')
exec('hexo server -p ${HEXO_SERVER_PORT}',(error, stdout, stderr) => {
        if(error){
                console.log('exec error: ${error}')
                return
        }
        console.log('stdout: ${stdout}');
        console.log('stderr: ${stderr}');
})
