/**
 * Load dependencies.
 */
const http = require('http');
const { Server } = require('node-static');

/**
 * Initialize.
 */
const server = new Server('./public');
http.createServer((req, res) => {
  req.addListener('end', () => {
    server.serve(req, res);
  }).resume();
}).listen(process.env.PORT || 3000, process.env.HOST || '0.0.0.0', function listener() {
  const address = this.address();
  // eslint-disable-next-line no-console
  console.log(`Project is running at http://${address.address}:${address.port}/`);
});
