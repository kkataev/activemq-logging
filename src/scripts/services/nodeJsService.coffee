angular.module('app')
	.service('nodeJsService', [
		'$log'
		(console) ->

			socket = io.connect('http://localhost:5001')

			onEvent = (name, callback) ->
				socket.on name, callback

			{
				on: onEvent
			}

])