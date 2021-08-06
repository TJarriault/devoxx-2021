const http = require('http')

const port = process.env.PORT

const server = http.createServer((req, res) => {
  let msg = {
    hello: 'Devoxx 2021!',
    node: process.env.MY_NODE_NAME,
    pod: process.env.MY_POD_NAME,
    ns: process.env.MY_POD_NAMESPACE,
    ip: process.env.MY_POD_IP,
    sa: process.env.MY_POD_SERVICE_ACCOUNT
  }
  res.statusCode = 200
  res.setHeader('Content-Type', 'text/json')
  res.end(JSON.stringify(msg))
})

server.listen(port, () => {
  console.log(`Server running at port ${port}`)
})
