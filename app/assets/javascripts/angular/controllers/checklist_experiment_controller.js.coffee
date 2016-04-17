checklistExperimentController = angular.module('checklistExperimentController', ['closing-checklist-directive', 'closingChecklistService'])

checklistExperimentController.controller 'ChecklistExperimentCtrl', [
  "$rootScope"
  "$scope"
  "$http"
  "ClosingChecklistService"
  ($rootScope, $scope, $http, checklistService) ->

    loan_num = "7446201"

    $scope.loading = true
    checklistService.loanNumber = loan_num
    checklistService.getChecklist()

    checklistService.whenChecklistLoads().then ->
      $scope.loading = false
]

