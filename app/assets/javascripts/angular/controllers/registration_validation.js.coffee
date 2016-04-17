registrationValidationController = angular.module('registrationValidationController', ['hide-element-directive', 'validation-results-directive', 'flow-thingy-result-directive', 'flow-result-directive', 'flowService', 'flowAdderService', 'yesno-question-directive', 'registration-checklist-directive'])

registrationValidationController.controller 'RegistrationValidationCtrl', [
  "$rootScope"
  "$scope"
  "$http"
  "$q"
  "$location"
  "FlowService"
  "AddFlow"
  "RegistrationChecklistService"
  ($rootScope, $scope, $http, $q, $location, FlowService, AddFlow, checklistService) ->

    $scope.getLoan = ->
      resetLoan()

      fetchLoan = $http.get("/registration/validations/search.json?id=" + $scope.loan_number )

      fetchLoan.then ((response) ->
        checklistService.loanNumber = $scope.loan_number
        $scope.loading_loan = false
        $scope.loan = response.data.loan

        $scope.all_flows = flowsForLoan()

        $scope.manual_fact_types = response.data.loan.manual_fact_types
        $scope.performValidations()
      ), (error) ->
        $scope.loading_loan = false
        $scope.loan_not_found = true

    resetLoan = ->
      $scope.loan = null
      $scope.loan_not_found = false
      $scope.loading_loan = true
      resetValidations()

    flowsForLoan = ->
      flows = $scope.info_flows.concat $scope.normal_flows
      if $scope.loan && $scope.loan.trid_loan
        flows = flows.concat(new Validation.RegistrationChecklistResult(checklistService))
      flows

    $scope.info_flows = AddFlow.adder('info_registration')
    $scope.normal_flows = AddFlow.adder('registration')

    $scope.all_flows = flowsForLoan()

    resetValidations = ->
      $scope.warnings = []
      $scope.errors = []
      $scope.loading_validation_flag = true
      $scope.validation_status = null
      _.each $scope.all_flows, (f) -> f.reset()

    addMessagesTo = (collection, messages) ->
      _.each messages, (message) ->
        collection.push message unless _.any collection, (other) -> other.text == message.text

    determineOverallStatus = ->
      if _.any($scope.all_flows, (f) -> f.status == "fail")
        "fail"
      else if _.any($scope.all_flows, (f) -> f.status == "review")
        "review"
      else
        "pass"

    $rootScope.$on 'ValidationWarningProcessed', ->
      newStatus = determineOverallStatus()
      if newStatus != $scope.validation_status
        $scope.performValidations()

    # this is dumb, is there a better way?
    data_compare = _.find $scope.all_flows, (f) -> f.name == "data_compare"
    data_compare.whenLoaded (dc) ->
      $scope.data_compare = dc

    $scope.saveFactTypes = () ->
      $scope.error_saving = false
      $scope.error_saving_message = null
      $scope.saving_facts = true
      $scope.fact_types_saved = false

      stuff = {
        manual_fact_types: {}
      }
      _.each $scope.manual_fact_types, (ft) ->
        stuff.manual_fact_types[ft.field_name] = ft.value

      save_data = $http.post("/manual_fact_types/#{$scope.loan_number}/save", stuff)

      save_data.then ((response) ->
        $scope.saving_facts = false
        $scope.fact_types_saved = true
      ), (error) ->
        $scope.saving_facts = false
        $scope.error_saving = true
        $scope.error_saving_message = error.data.error

    $scope.performValidations = (button) ->
      resetValidations()
      $scope.validating = true

      event = $http.get("/decisionator_flows/create_new_event.json?id=" + $scope.loan_number + "&validation_type=registration")

      event.then ((response) ->
        $scope.event_id = response.data.id
        promises = _.map $scope.all_flows, (f) ->
          p = f.run $http, $scope.loan_number, $scope.event_id, 'registration'
          p.then ->
            addMessagesTo $scope.warnings, f.warnings
            addMessagesTo $scope.errors, f.errors

        $q.all(promises).then ->
          $scope.validation_status = determineOverallStatus()
          $scope.loading_validation_flag = false
      )

    $scope.setClass = (flow_status) ->
      if flow_status == 'fail'
        'failing-validation'
      else if flow_status == 'pass'
        'passing-validation'

    $scope.originalValues = {}
    $scope.storeOrigValue = (name, value) ->
      $scope.originalValues[name] = value

    $scope.saving = {}
    $scope.error_saving = {}
    $scope.saveManualEntry = (name, value) ->
      return if value == $scope.originalValues[name]
      mfts = {}
      mfts[name] = value
      $scope.saving[name] = true
      $scope.error_saving[name] = null
      p = $http.post("/manual_fact_types/#{$scope.loan_number}/save", { manual_fact_types: mfts })
      p.then -> $scope.saving[name] = false
      p.catch (e) ->
        $scope.error_saving[name] = e.data.message
        $scope.saving[name] = false

    if $location && $location.search() && $location.search().loan_num
      $scope.loan_number = $location.search().loan_num
      $scope.getLoan()

]
