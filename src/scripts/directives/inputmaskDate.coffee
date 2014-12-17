angular.module('app').directive 'inputmaskDate', [
	'$log','$location', '$parse', '$rootScope'
	(console, location, $parse, $rootScope) ->
		restrict:'A'
		require: '^ngModel'
		link: (scope, element, attrs, ctrl) ->			
			mask = attrs.mask || 'yyyy/mm/dd'
			element.inputmask(mask)
			parsed = $parse(attrs.ngModel)
]