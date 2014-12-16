angular.module('app')
	.service('notificationService', [
		'$log', '$resource', '$injector', 'notificationAdapter', '$rootScope', 'notificationsList' 
		(console, $resource, $injector, notificationAdapter, $rootScope, notificationsList) ->

			adapter = $injector.get(notificationAdapter)
			instance = {}

			angular.forEach notificationsList, (value, key) -> 
				instance[value] = (callback) -> adapter.on value, callback
				instance[value] (data) -> $rootScope.$broadcast value, data
			instance

])