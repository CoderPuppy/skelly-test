app = require \./shared

server = require(\skelly/server)(app, './browser')
server.listen 3000