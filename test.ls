app = require \./shared
live = require \skelly/live

app.main-template(new live.KV(
	url:
		pathname: '/'
)).stream!.on \end, ->
	console.log \end
.pipe(process.stdout)