angular.module('app')
	.service('signalrService', [
		'$log'
		(console) ->

			socket = jQuery.connection.serviceTrackerHub

			onEvent = (name, callback) ->
				return unless socket
				socket.client[name] = (data) -> callback(data)
				$.connection.hub.start()
				
			{
				on: onEvent
			}
		
])
