#Menu system for the client.

crypto = require 'crypto'
async = require 'async'
Encryption = require './encryption'

# getLine
# -------
# Gets the current line from the terminal and calls `callback` when done.  
# `callback(line)` - Called when the user is done typing a line.
# `line` - The line that was input.
getLine = (callback) ->
	process.stdin.resume()
	process.stdin.setEncoding 'utf8'
	process.stdin.once 'data', (line) ->
		process.stdin.pause()
		callback line.trim()

# Menu
# ====
# Runs and operates the menu (command prompt).
class Menu
	# constructor
	# -----------
	# `con` - Connection object with the server.  
	# `key` - The key used for encryption with the server.  
	# `server` - The name of the server.
	constructor: (@con, @key, @server) ->
		@user = "[anonymous]"
		@loggedin = false
		@enc = new Encryption @key
	
	# start
	# -----
	# Take over the interface and start listening for data.
	start: =>
		@prompt()
	
	# prompt
	# ------
	# Prompt the user for the next command and execute that command.
	prompt: =>
		# Set to false when the prompt should not run again in the
		# next command.
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
	
	# processInput
	# ------------
	# Process the data entered and send it to the functions to process it.
	processInput: (input, doneProcessing) =>
		args = input.split ' '
		for arg in args
			arg = arg.trim()
		
		# Remove empty arguments
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
			when "logout" then @logout doneProcessing, args[1..]
			else
				console.log "Unknown command. For help type 'help'"
				doneProcessing()

	# Input Commands
	# ==============
	# The following commands represent the various functions the user can
	# call.

	# printHelp
	# ---------
	# Displays the help message to the user.  
	# Usage: `help`
	printHelp: =>
		console.log """
			Commands:
			exit - Exit the prompt and disconnect.
			login - Login to the server.
			logout - Logout of the server but maintain connection.
			createuser - Creates a new user account.
			help - Prints this help page.
			"""

	# createUser
	# ----------
	# Creates a new user on the server.  
	# Usage: `createuser name`
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
	
	# login
	# -----
	# Logs the user into the server.  
	# Usage: `login [name]`
	login: (doneCallback, args) =>
		name = null
		password = null
		passwordHash = null

		if args.length >= 1
			name = args[0]

		if @loggedin
			# Already logged in, need to log out before logging in again.
			console.log "Already logged in."
			doneCallback null
			return

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
						@loggedin = true
					else
						console.error "Login failed."
					
					if response.message?
						console.log response.message

					callback null
			(callback) =>
				doneCallback null
				callback null
		]

	# logout
	# ------
	# Logs the user out of the server.  
	# Usage: `logout`
	logout: (doneCallback, args) =>
		if @loggedin
			# Send a logout command to the server
			@con.write @enc.encObj {command: "logout"}
			@con.once 'data', (data) =>
				response = @enc.decObj data
				if response.success
					@loggedin = false
					@user = "[anonymous]"
				else
					console.log response.message
				doneCallback()

		else
			console.log "Not currently logged in."



module.exports = Menu

