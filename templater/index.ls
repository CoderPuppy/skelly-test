require! stream
require! through2
# convoy-stream = require \convoy-stream

live = require \skelly/live

tags = [ \html \head \body \title \meta \script \p \link \a \div \span \style \canvas \button \input ]

autoclosing =
	meta: true
	img: true
	link: true
	input: true

# convoy-stream = ->
# 	stream = require(\convoy-stream)!
# 	stream.queue = (s) ->
# 		s.pipe stream.create-stream!
# 	stream

class convoy-stream extends stream.Readable
	~>
		super!

		@streams = []

	_read: ->
		if @streams.length
			i = 0
			while @streams[i]
				stream = @streams[i]

				while stream.buffer.length
					buf = stream.buffer.shift!
					if buf instanceof Buffer
						console.log 'queuing: %s', buf.to-string \utf-8
					else
						console.log 'queuing: %s', buf
					@push buf

				# console.log stream

				if stream.done
					# console.log 'removing'
					@streams.shift!
				else
					i++

			if @streams.length == 0
				@push null	
		else
			@push null

	queue: (stream) ->
		data =
			done: false
			buffer: []

		@streams.push data

		stream.on \end, ~>
			data.done = true
			# console.log \end
			@_read!
		.on \data, (buf) ~>
			# if buf instanceof Buffer
			# 	console.log 'got: %s', buf.to-string \utf-8
			# else
			# 	console.log 'got: %s', buf
			data.buffer.push buf

		# stream.resume!

get = (val) ->
	if val instanceof live.Base
		val.get!
	else
		val

templater = (fn, extras = {}) ->
	(client) ->
		stream: ->
				c = convoy-stream!

				h =
					client: client

					doctype: (type) ->
						src = new class extends stream.Readable
							_read: ->
								@push "<!doctype #{get type}>"
								@push null

						c.queue src

						h

					template: (fn, ...args) ->
						h.tag \div, ~>
							c.queue fn(client, ...args).stream! #.on(\end, -> console.log \end)

							# fn(h, client, ...args)

					text: (content) ->
						if content instanceof live.Base
							content = content.get!

						src = new class extends stream.Readable
							_read: ->
								@push content
								@push null

						c.queue src

						h

					tag: (name, attrs, content) ->
						if typeof(attrs) != 'object' or attrs instanceof live.Base
							content = attrs
							attrs = {}

						if content instanceof live.Base
							content = content.get!

						c.queue new class extends stream.Readable
							_read: ->
								@push "<#{name}"

								for key, val of attrs
									@push " #{key}=#{JSON.stringify(get(val))}"

								if autoclosing[name]
									@push '/>'
								else
									@push '>'

									switch typeof(content)
									| \string => @push content

								@push null

						if not autoclosing[name]
							if typeof(content) == \function
								content(client)

							c.queue new class extends stream.Readable
								_read: ->
									@push "</#{name}>"
									@push null

						h

				for let name in tags
					h[name] = (...args) ~> h.tag name, ...args

				h <<< extras

				fn h, client

				c

		bind: (el, dom) ->
			cur = el

			h =
				doctype: -> h
				template: (fn, ...args) ->
					dom.live.template()

			for let name in tags
				h[name] = (...args) -> h.tag name, ...args

			h <<< extras

			fn(h)


module.exports = templater