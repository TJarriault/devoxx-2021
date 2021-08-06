const http = require('http')

const port = process.env.PORT
const node = process.env.MY_NODE_NAME
const pod = process.env.MY_POD_NAME
const ns = process.env.MY_POD_NAMESPACE
const ip = process.env.MY_POD_IP
const sa = process.env.MY_POD_SERVICE_ACCOUNT

const server = http.createServer((req, res) => {
  let msg = '';

  http.get('http://devoxx-remote-service:3000', (response) => {
    // called when a data chunk is received.
    response.on('data', (chunk) => {
      msg += chunk;
    });

    // called when the complete response is received.
    response.on('end', () => {
      message = JSON.parse(msg)

      console.log(message.hello);

      res.statusCode = 200
      res.setHeader('Content-Type', 'text/html')
      res.write('<h1>Hello, ' + message.hello + '</h1>')
      res.write('<div>I am the pod <b>'+ pod  + '</b></div>')
      res.write('<article>')
      res.write('I received the response coming from <ul>')
      res.write('<li>pod: <b>'+message.pod+'</b></li>')
      res.write('<li>node: <b>'+message.node+'</b></li>')
      res.write('<li>namespace: <b>'+message.ns+'</b></li>')
      res.write('<li>ip: <b>'+message.ip+'</b></li>')
      res.write('<li>service account: <b>'+message.sa+'</b></li>')
      res.write('</article>')
      res.end()
    });
  }).on("error", (error) => {
    console.log("Error: " + error.message);
    res.statusCode = 503
    res.statusMessage = error.message
    res.end(error.message)
  });

})

server.listen(port, () => {
  console.log(`Server running at port ${port}`)
})
