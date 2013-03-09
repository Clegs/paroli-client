###
# encryption.coffee - In charge of encrypting and decrypting the data
# being sent to the user and being stored on the disk.
###

crypto = require 'crypto'

class Encryption
	constructor: (@key, @privateKey) ->
		
	encode: (data) =>
		cipher = crypto.createCipher 'aes256', @key
		cipher.update(data, 'utf8', 'base64') + cipher.final('base64')
	
	decode: (data) =>
		decipher = crypto.createDecipher 'aes256', @key
		"#{decipher.update data, 'base64'}#{decipher.final()}"
	
	encObj: (obj) =>
		@encode JSON.stringify obj
	
	decObj: (data) =>
		JSON.parse @decode data

module.exports = Encryption

