app = angular.module 'app', ['ngResource', 'ngRoute', 'ui.bootstrap', 'hill30']

angular.module('app').run ['$rootScope', '$log', ($rootScope, $log) ->
	# fire an event related to the current route
]