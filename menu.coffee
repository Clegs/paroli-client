###
	Menu system for the client.
###

crypto = require 'crypto'
async = require 'async'
Encryption = require './encryption'

getLine = (callback) ->
	process.stdin.resume()
	process.stdin.setEncoding 'utf8'
	process.stdin.once 'data', (line) ->
		process.stdin.pause()
		callback line.trim()
	



class Menu
	constructor: (@con, @key, @server) ->
		@user = "nobody"
		@enc = new Encryption @key
	
	# Take over the interface and start listening for data.
	start: =>
		@prompt()
	
	prompt: =>
		again = true

		async.waterfall [
			(callback) =>
				process.stdin.write "#{@user}@#{@server}$ "
				getLine (line) ->
					callback null, line
			(line, callback) =>
				switch line
					when "exit"
						again = false
						@con.end()
						callback null
					when "help"
						@printHelp()
						callback null
					when "login" then @login(callback)
					else
						console.log "Unknown command. For help type 'help'"
						callback null
				#callback null
			(callback) =>
				@prompt() if again
				callback null
		]

	printHelp: =>
		console.log """
			Commands:
			exit - Exit the prompt and disconnect.
			login - Login to the server.
			new - Creates a new user account.
			help - Prints this help page.
			"""

	createUser: =>
		name = null
		password = null

		async.waterfall [
			(callback) =>
				process.stdout.write "Username: "
				getLine (line) =>
					name = line
					callback null
			(callback) =>
				process.stdout.write "Password: "
				getLine (line) =>
					password = line
					callback null
			(callback) =>
				callback null
				
		]
	
	login: (doneCallback) =>
		name = null
		password = null
		passwordHash = null

		async.waterfall [
			(callback) =>
				process.stdout.write "Username: "
				getLine (line) =>
					name = line
					callback null
			(callback) =>
				process.stdout.write "Password: "
				getLine (line) =>
					password = line
					callback null
			(callback) =>
				hash = crypto.createHash "sha512"
				hash.update "#{name}#{password}", 'utf8'
				passwordHash = hash.digest 'base64'
				logindata = {}
				logindata.command = "login"
				logindata.user = name
				logindata.password = passwordHash
				@con.write @enc.encObj logindata
				@con.once 'data', (data) =>
					console.log "Got: #{data}"
					response = @enc.decObj data
					console.log "Response: #{JSON.stringify response}"
					@user = name
					callback null
			(callback) =>
				doneCallback null
				callback null
		]


module.exports = Menu

