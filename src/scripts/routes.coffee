angular.module('app').config ['$routeProvider', ($routeProvider) ->
	$routeProvider.when('/messages',
		templateUrl: 'views/messages.html', reloadOnSearch: false
	)
	.otherwise
		redirectTo: '/messages'
]