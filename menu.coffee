###
	Menu system for the client.
###

crypto = require 'crypto'
async = require 'async'

getLine = (callback) ->
	process.stdin.resume()
	process.stdin.setEncoding 'utf8'
	process.stdin.once 'data', (line) ->
		process.stdin.pause()
		callback line.trim()


class Menu
	constructor: (@con, @key) ->
	
	# Take over the interface and start listening for data.
	start: =>
		@prompt()
		
	prompt: =>
		again = true

		async.waterfall [
			(callback) =>
				process.stdin.write "> "
				getLine (line) ->
					callback null, line
			(line, callback) =>
				switch line
					when "exit"
						again = false
						@con.end()
					when "help" then @printHelp()
					else
						console.log "Unknown command. For help type 'help'"
				callback null
			(callback) =>
				@prompt() if again
				callback null
		]

	printHelp: =>
		console.log """
			Commands:
			exit - Exit the prompt and disconnect.
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


module.exports = Menu

