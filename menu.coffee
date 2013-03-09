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
		@user = "[anonymous]"
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
				@processInput line, (stop) =>
					if stop then again = false
					callback null
			(callback) =>
				@prompt() if again
				callback null
		]
	
	processInput: (input, doneProcessing) =>
		args = input.split ' '
		for arg in args
			arg = arg.trim()
		
		# Remove emptpy arguments
		args.splice index, 1 for index, value of args when not value
		
		unless args.length
			doneProcessing()
			return
		
		switch args[0]
			when "exit"
				@con.end()
				doneProcessing true
			when "help"
				@printHelp()
				doneProcessing()
			when "login" then @login doneProcessing, args[1..]
			else
				console.log "Unknown command. For help type 'help'"
				doneProcessing()

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
	
	login: (doneCallback, args) =>
		name = null
		password = null
		passwordHash = null

		if args.length >= 1
			name = args[0]

		async.waterfall [
			(callback) =>
				if name
					callback null
				else
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
					response = @enc.decObj data
					if response.success
						@user = name
					else
						console.error "Login failed."
					
					if response.message?
						console.log response.message

					callback null
			(callback) =>
				doneCallback null
				callback null
		]


module.exports = Menu

