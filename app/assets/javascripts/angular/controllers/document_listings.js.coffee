documentListingController = angular.module('documentListingController', [])

documentListingController.controller 'DocumentListingCtrl', [
  "$rootScope"
  "$scope"
  ($rootScope, $scope) ->

    $scope.toggleMarks = (variable_ref_string) ->
      $scope[variable_ref_string] = !$scope[variable_ref_string]
]