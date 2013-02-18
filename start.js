#!/usr/bin/env node

// start.js - Starts the Paroli Client

var net = require('net');

var user, pass, server, port;

var onData = null;

process.stdin.resume();
process.stdin.setEncoding('utf8');

process.stdin.on('data', function(d) {
	if(onData == null)
		return;
	
	onData(d);
});

var getUser = function(d) {
	user = d.trim();
	console.log('Username set to %s', user);
	onData = getPass;
	process.stdout.write('Password: ');
};

var getPass = function(d) {
	pass = d.trim();
	console.log('Password set to %s', pass);
	onData = getServer;
	process.stdout.write('Server: ');
};

var getServer = function(d) {
	server = d.trim();
	console.log('Server set to %s', server);
	onData = getPort;
	process.stdout.write('Port: ');
};

var getPort = function(d) {
	port = parseInt(d.trim());
	console.log('Port set to %d', port);
	onData = null;
};

// Get required information
process.stdout.write('User: ');
onData = getUser;


