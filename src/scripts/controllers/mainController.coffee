angular.module('app')
	.controller('mainController', [
		'$scope', '$log', '$location', '$rootScope', 'messagesResource', 'debounce', '$routeParams'
		($scope, console, $location, $rootScope, messagesResource, debounce, $routeParams) ->


			revisionToRequestData = 0
			defaultDebounceTime = 350
			$scope.shared = {}

			# work with route params

			refreshRouteParams = () ->
				$location.search if $scope.nameFilter then { nameFilter: $scope.nameFilter } else {}

			setFilterFromRouteParams = () ->
				$scope.nameFilter = $routeParams.nameFilter if $routeParams.nameFilter

			$scope.setFilterDebounced = debounce(() ->
				refreshRouteParams()
				forceDataAsyncLoad()
			, defaultDebounceTime, false)

			$scope.messages =
					get: (index, count, success)->
						options = {}
						options.offset = index - 1
						options.count = count
						options.nameFilter = $scope.nameFilter if $scope.nameFilter

						successProccessed = (result) ->
							success(result)

						messagesResource.list(options, successProccessed)

					revision: ->
						revisionToRequestData

				forceDataAsyncLoad = () ->
					revisionToRequestData++

			setFilterFromRouteParams()

	])