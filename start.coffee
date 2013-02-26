# start2.coffee - Starts the Paroli Client

net = require 'net'

onData = null

user = null
pass = null
server = null
port = null

process.stdin.resume()
process.stdin.setEncoding 'utf8'

process.stdin.on 'data', (d) ->
	if onData is null
		return
	
	onData(d)

getUser = (d) ->
	user = d.trim()
	console.log "Username set to #{user}"
	onData = getPass
	process.stdout.write 'Password: '

getPass = (d) ->
	pass = d.trim()
	console.log "Passowrd set to #{pass}"
	onData = getServer
	process.stdout.write('Server: ')

getServer = (d) ->
	server = d.trim()
	console.log "Server set to #{server}"
	onData = getPort
	process.stdout.write 'Port: '

getPort = (d) ->
	port = parseInt d.trim()
	console.log "Port set to #{port}"
	onData = null

# Get required information
process.stdout.write 'User: '
onData = getUser

