app = angular.module('validation-results-directive', [])
app.directive "validationResults", ->
  restrict: "E"
  scope:
    errors: "=errors"
    warnings: "=warnings"
    loan_number: "=loanNumber"
    validation_type: "=validationType" #underwriter, preclosing, registration
    
  templateUrl: "validation_results.html"
  controller: ValidationResultsDirectiveCtrl
  
class ValidationResultsDirectiveCtrl
  constructor: ($rootScope, $scope, $http) ->
    $scope.uniqueErrors = ->
      _.uniq $scope.errors

    $scope.is_reviewed = (warning) ->
      !!warning[2]

    $scope.is_not_reviewed = (warning) ->
      !warning[2]

    $scope.get_user_name = (warning) ->
      warning[2] && warning[2].user_name

    $scope.get_created_at = (warning) ->
      warning[2] && warning[2].created_at

    $scope.setFlag = (warning) ->
      return false if $scope.is_reviewed(warning)
      $http.post('/' + $scope.validation_type + '/validations/process_validation_alert.json?lid=' + $scope.loan_number + '&rid=' + warning[0]).then (response) ->
        warning[2] = response.data
      $rootScope.$emit 'ValidationWarningProcessed'

ValidationResultsDirectiveCtrl.$inject = [ "$rootScope", "$scope", "$http" ]
window.ValidationResultsDirectiveCtrl = ValidationResultsDirectiveCtrl
