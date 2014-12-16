angular.module('app').factory('httpInterceptor', ["$q", "$rootScope", ($q, $rootScope) ->

	###response: (response) ->

		#$rootScope.$broadcast "success:#{response.status}", response

		response || $q.when(response)###

	responseError: (response) ->

		#$rootScope.$broadcast "error_#{response.status}", response

		returnObject = {}
		returnObject = $q.reject response

		if response.status isnt 403

			return returnObject if not (alertElement = angular.element('#httpErrorsBox'))
			return returnObject if not (contentElement = alertElement.find('[data-content]'))

			alertFullMessage = 'Http response error (' + response.status + '). ' + (JSON.stringify(response.data) if response.data)
			console.log(alertFullMessage)

			alertShortMessage = 'Http error, see console log for details...'
			contentElement.html(alertShortMessage)
			alertElement.css('display', "block")

		else

			return returnObject if not(dialogOpenerElement = angular.element('#permissionDeniedDialogOpener'))

			dialogOpenerElement.click()

		returnObject

])

angular.module('app').config(['$httpProvider', ($httpProvider) ->
	$httpProvider.interceptors.push('httpInterceptor')
])
