app = angular.module('funding-checklist-directive', ['fundingChecklistService'])
app.directive "fundingChecklist", ->
  restrict: "E"
  scope:
    loan_number: "=loanNumber"

  templateUrl: "funding_checklist.html"
  controller: FundingChecklistDirectiveCtrl
  controllerAs: 'ctrl'

class FundingChecklistDirectiveCtrl
  constructor: ($rootScope, $scope, $http, checklistService) ->
    this.$rootScope = $rootScope
    this.$scope = $scope
    this.$http = $http
    this.checklistService = checklistService

  loadChecklist: ->
    this.$scope.loading = true
    this.checklistService.getChecklist()
    p = this.checklistService.whenChecklistLoads()
    p.then (c) =>
      this.$scope.checklist = c
      this.$scope.loading = false
      this.$scope.saved_checklist = false
      this.$scope.show_checklist = true
    p.catch (e) =>
      this.$scope.loading_error = true
      this.$scope.checklist_error = e

  saveChecklist: (checklist, button) ->
    p = this.checklistService.saveChecklist(checklist, button)
    p.then (c) => 
      this.$scope.saved_checklist = true

  cancelChecklist: ->
    this.$scope.show_checklist = false

FundingChecklistDirectiveCtrl.$inject = ["$rootScope", "$scope", "$http", "FundingChecklistService"]
window.FundingChecklistDirectiveCtrl = FundingChecklistDirectiveCtrl