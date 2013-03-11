# In charge of encrypting and decrypting the data
# being sent to the user and being stored on the disk.

crypto = require 'crypto'

# Encryption
# ==========
# Handles the encryption and decription of data between the server and
# the client.
class Encryption
	# constructor
	# -----------
	# Creates the encryption object.  
	# `key` - The passphrase being used for the encryption. Normally sent
	# to the server from the client.
	constructor: (@key, @privateKey) ->
	
	# encode
	# ------
	# Encode data using the key to be sent to the user.  
	# `data` - The data to encode.  
	# Returns the encoded data in base64.
	encode: (data) =>
		cipher = crypto.createCipher 'aes256', @key
		cipher.update(data, 'utf8', 'base64') + cipher.final('base64')
	
	# decode
	# ------
	# Decodes the data that has been encoded using the `encode` method.  
	# `data` - The data to decode.
	# Returns the decoded data as a string.
	decode: (data) =>
		decipher = crypto.createDecipher 'aes256', @key
		"#{decipher.update data, 'base64'}#{decipher.final()}"
	
	# encObj
	# ------
	# Encodes an object.  
	# `obj` - Object to be encoded.  
	# Returns the encoded object in base64.
	encObj: (obj) =>
		@encode JSON.stringify obj
	
	# decObj
	# ------
	# Decodes encoded data into an object.  
	# `data` - base64 data to decode.  
	# Returns an object represented by the encoded data.
	decObj: (data) =>
		JSON.parse @decode data

module.exports = Encryption

