fundingValidationsController = angular.module('fundingValidationsController', ['hide-element-directive', 'ui.bootstrap', 'fundingChecklistService', 'funding-checklist-directive', 'settlement-agent-directive', 'settlementAgentAuditService'])

fundingValidationsController.controller 'FundingValidationsCtrl', [
  "$rootScope"
  "$scope"
  "$http"
  "$q"
  "$location"
  "FundingChecklistService"
  "SettlementAgentAuditService"
  ($rootScope, $scope, $http, $q, $location, checklistService, auditService) ->

    $scope.getLoan = ->
      resetLoan()

      fetchLoan = $http.get("/funding/validations/search.json?id=" + $scope.loan_number )

      fetchLoan.then ((response) ->
        checklistService.loanNumber = $scope.loan_number
        auditService.loanNumber = $scope.loan_number
        $scope.loading_loan = false
        $scope.load_audit = false
        $scope.loan = response.data
      ), (error) ->
        $scope.loading_loan = false
        $scope.loan_not_found = true

    resetLoan = ->
      $scope.loan = null
      $scope.loan_not_found = false
      $scope.loading_loan = true
      $scope.done_audit = false
      
    if $location && $location.search() && $location.search().loan_num
      $scope.loan_number = $location.search().loan_num
      $scope.getLoan()
]