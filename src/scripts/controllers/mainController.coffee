angular.module('app')
	.controller('mainController', [
		'$scope', '$log', '$location', '$rootScope', 'messagesResource', 'debounce', '$routeParams'
		($scope, console, $location, $rootScope, messagesResource, debounce, $routeParams) ->

			revisionToRequestData = 0
			defaultDebounceTime = 350

			refreshRouteParams = () ->
				$location.search if $scope.filters then $scope.filters else {}

			setFilterFromRouteParams = () ->
				$scope.filters = $routeParams if $routeParams

			$scope.setFilterDebounced = debounce(() ->
				refreshRouteParams()
				forceDataAsyncLoad()
			, defaultDebounceTime, false)

			$scope.messages =
					get: (index, count, success)->
						options = {}
						options = $scope.filters if $scope.filters
						options.offset = index - 1
						options.count = count

						successProccessed = (result) ->
							success(result)

						messagesResource.list(options, successProccessed)

					revision: ->
						revisionToRequestData

				forceDataAsyncLoad = () ->
					revisionToRequestData++

			$scope.clear = (_filter) -> 
				delete $scope.filters[_filter]
				$scope.setFilterDebounced()
				
			setFilterFromRouteParams()

	])