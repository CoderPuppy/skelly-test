require! skelly
require! stream

app = skelly!

# app.route '/' (client) ->
# 	create-template

templater = require \./templater

# main-template = (h) ->
# 	h.doctype \html
# 	h.html ->
# 		h.head ->
# 			h.meta charset: \utf-8
# 			h.title 'hi'
# 			h.script src: \bundle.js

# 		h.body ->
# 			h.p 'foo'

dslify = require \dslify .transform

other-template = dslify (client) ->
	text 'foobar'
	p client.get(\url).get(\pathname)

main-template = dslify (client) ->
	doctype \html
	html ->
		console.log 'in html'
		head ->
			meta charset: \utf-8
			title 'hi'
			script src: \bundle.js

		body ->
			p 'foo'
			p -> a href: '/foobar', 'foobar'
			p -> a href: '/foo', 'foo'
			p -> a href: '/bar', 'bar'
			p -> a href: '/baz', 'baz'
			p -> a href: '/hi', 'hi'
			template other-template

app.other-template = templater other-template
app.main-template = templater main-template, { other-template: app.other-template, console }

# other-template = (client, name) ->
# 	{
# 		stream: ->
# 			console.log name

# 			new class extends stream.Readable
# 				_read: ->
# 					@push """
# 					<h1>#{name}</h1>
# 					foobar
# 					<p id=pathname2>#{client.get \url .get \pathname .get! }</p>
# 					"""
# 					@push null

# 		bind: (el, dom) ->
# 			window.client = client
# 			client.get('url').get('pathname').pipe(dom.live.text(el.query-selector('#pathname2')))

# 		unbind: (el) ->

# 	}

# app.main-template = (client) ->
# 	{
# 		write-head: (res) ->
# 			res.writeHead 200, 'Content-Type': 'text/html'

# 		stream: ->
# 			new class extends stream.Readable
# 				_read: ->
# 					@push """
# 					<!doctype html>
# 					<html>
# 						<head>
# 							<meta charset=utf-8>
# 							<script src=bundle.js></script>
# 						</head>
# 						<body>
# 							<p><a href=hi>hi</a></p>
# 							<p><a href=foo>foo</a></p>
# 							<p><a href=bar>bar</a></p>
# 							<p><a href=baz>baz</a></p>
# 							<p>foobarbaz</p>
# 							<p id=pathname>#{client.get \url .get \pathname .get! }</p>

# 							<div id=othertemplate>
# 					"""
# 					other-template(client).stream!.on \end, ~>
# 						@push """
# 								</div>
# 							</body>
# 						</html>
# 						"""
# 						@push null
# 					.on \data, (buf) ~>
# 						@push buf

# 		bind: (el, dom) ->
# 			window.client = client
# 			client.get('url').get('pathname').pipe(dom.live.text(el.query-selector('#pathname')))
# 			client.get('url').get('pathname').map (path) ->
# 				other-template(client, path)
# 			.pipe dom.live.template(el.query-selector('#othertemplate'), dom)

# 		unbind: (el) ->

# 	}

module.exports = app