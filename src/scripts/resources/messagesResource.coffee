angular.module('app')
	.factory('messagesResource', ['$resource', ($resource) ->
		$resource 'api/log', {}, {
			list:	{ method: 'GET', isArray: true } 
		}
	])