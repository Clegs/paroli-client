###
 start.coffee - Starts a sample client to interact with the paroli server
 and test its features.
###

net = require 'net'
ursa = require 'ursa'
async = require 'async'
crypto = require 'crypto'

# Get the next line from the console and call 'callback' with the line
# as the argument.
getLine = (callback) ->
	process.stdin.resume()
	process.stdin.setEncoding 'utf8'
	process.stdin.once 'data', (line) ->
		process.stdin.pause()
		callback line.trim()

# Get the next data from the connection 'con'
getData = (con, callback, encoding) ->
	con.setEncoding encoding if encoding
	con.once 'data', (data) ->
		callback data

user = "user"
pass = "pass"
server = "localhost"
port = 6743
con = null
publicKey = null
key = null

sendEnc = (data) ->
	cipher = crypto.createCipher 'aes256', key
	buf1 = new Buffer cipher.update(data), 'binary'
	buf2 = new Buffer cipher.final(), 'binary'
	out = Buffer.concat [buf1, buf2]
	con.write out

async.waterfall [
	(callback) ->
		process.stdout.write "User: (#{user}) "
		getLine (line) ->
			user = line if line
			callback null
	(callback) ->
		process.stdout.write "Password: (#{pass}) "
		getLine (line) ->
			pass = line if line
			callback null
	(callback) ->
		process.stdout.write "Server: (#{server}) "
		getLine (line) ->
			server = line if line
			callback null
	(callback) ->
		process.stdout.write "Port: (#{port}) "
		getLine (line) ->
			port = parseInt line if line
			callback null
	(callback) ->
		# Connect to the server
		con = net.connect port, server, ->
			console.log "Client Connected!"

		con.on 'end', ->
			console.log "Server Disconnected"
			process.exit 1

		getData con, (data) ->
			publicKeyPem = data
			console.log publicKeyPem
			publicKey = ursa.createPublicKey publicKeyPem, 'utf8'
			callback null
		, 'utf8'
	(callback) ->
		# Generate a random key
		crypto.randomBytes 256/8, (ex, buf) ->
			throw ex if ex
			key = buf
			console.log "Key: #{key}"
			callback null
	(callback) ->
		# Send the key
		con.write publicKey.encrypt key
		sendEnc "Hello World!"
		console.log 'Sent'
		callback null
]

