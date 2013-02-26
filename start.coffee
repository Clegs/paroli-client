# start2.coffee - Starts the Paroli Client

net = require 'net'
ursa = require 'ursa'

onData = null

user = 'user'
pass = 'pass'
server = 'localhost'
port = 6743
con = null
publicKey = null

process.stdin.resume()
process.stdin.setEncoding 'utf8'

process.stdin.on 'data', (d) ->
	if onData is null
		return
	
	onData(d)

getUser = (d) ->
	d = d.trim()
	user = d if d
	console.log "Username set to #{user}"
	onData = getPass
	process.stdout.write "Password: (#{pass}) "

getPass = (d) ->
	d = d.trim()
	pass = d if d
	console.log "Passowrd set to #{pass}"
	onData = getServer
	process.stdout.write "Server: (#{server}) "

getServer = (d) ->
	d = d.trim()
	server = d if d
	console.log "Server set to #{server}"
	onData = getPort
	process.stdout.write "Port: (#{port}) "

getPort = (d) ->
	d = d.trim()
	port = parseInt d if d
	console.log "Port set to #{port}"
	onData = dataSender
	connect()

# Get required information
process.stdout.write "User: (#{user}) "
onData = getUser

# Connect to the server
connect = ->
	con = net.connect port, server, ->
		console.log 'Client Connected!'
	
	con.on 'data', (data) ->
		publicKeyPem = data.toString()
		console.log publicKeyPem
		publicKey = ursa.createPublicKey publicKeyPem, 'utf8'
		con.on 'data', dataListener
	
	con.on 'end', ->
		console.log 'Server Disconnected'
		process.exit 1



# Listen for incomming data
dataListener = (data) ->
	console.log data


# Send data
dataSender = (data) ->
	# Send the data
	#encData = publicKey.encrypt data
	#con.write encData
	sendData = JSON.stringify
			'user': user
			'pass': pass
	encData = publicKey.encrypt sendData
	con.write encData
			

