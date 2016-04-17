initialDisclosureValidationController = angular.module('initialDisclosureValidationController', ['hide-element-directive', 'validation-results-directive', 'flow-result-directive', 'validation-message-directive', 'flowService', 'flowAdderService'])

initialDisclosureValidationController.controller 'InitialDisclosureValidationCtrl', [
  "$rootScope"
  "$scope"
  "$http"
  "$q"
  "$location"
  "FlowService"
  "AddFlow"
  ($rootScope, $scope, $http, $q, $location, FlowService, AddFlow) ->

    $scope.info_flows = AddFlow.adder('info_initial_disclosure')
    $scope.normal_flows = AddFlow.adder('initial_disclosure')
    
    all_flows = $scope.info_flows.concat $scope.normal_flows

    $scope.getLoan = ->
      resetLoan()

      fetchLoan = $http.get("/initial_disclosure/validations/search.json?id=" + $scope.loan_number )

      fetchLoan.then ((response) ->
        $scope.loading_loan = false
        $scope.loan = response.data.loan
        $scope.manual_fact_types = response.data.loan.manual_fact_types
        # if _.all($scope.manual_fact_types, (ft) -> !!ft.value)
        $scope.performValidations()
      ), (error) ->
        $scope.loading_loan = false
        $scope.error_loading_loan = true
        $scope.error_loading_message = error.data.error

    resetLoan = ->
      $scope.loan = null
      $scope.error_loading_loan = false
      $scope.error_loading_message = null
      $scope.loading_loan = true
      resetValidations()

    resetValidations = ->
      $scope.validating = false
      $scope.warnings = []
      $scope.errors = []
      $scope.validation_status = null
      $scope.loading_validation_flag = true
      $scope.saving_facts = false
      $scope.error_saving = false
      $scope.error_saving_message = null
      $scope.fact_types_saved = false
      _.each all_flows, (f) -> f.reset()

    addMesssagesTo = (collection, messages) ->
      _.each messages, (message) ->
        collection.push message unless _.any collection, (other) -> other.text == message.text

    determineOverallStatus = ->
      if _.any(all_flows, (f) -> f.status == "fail")
        "fail"
      else if _.any(all_flows, (f) -> f.status == "review")
        "review"
      else
        "pass"

    $rootScope.$on 'ValidationWarningProcessed', ->
      newStatus = determineOverallStatus()
      if newStatus != $scope.validation_status
        $scope.performValidations()
        #
    # this is dumb, is there a better way?
    data_compare = _.find all_flows, (f) -> f.name == "data_compare"
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

      $http.get("/decisionator_flows/create_new_event.json?id=" + $scope.loan_number + "&validation_type=initial_disclosure" ).then (response) ->
        $scope.event_id = response.data.id
        
        promises = _.map all_flows, (f) ->
          p = f.run $http, $scope.loan_number, $scope.event_id, 'initial_disclosure'
          p.then ->
            addMesssagesTo $scope.warnings, f.warnings
            addMesssagesTo $scope.errors, f.errors

        $q.all(promises).then ->
          $scope.validation_status = determineOverallStatus()
          $scope.loading_validation_flag = false

    $scope.setClass = (flow_status) ->
      if flow_status == 'fail'
        'failing-validation'
      else if flow_status == 'pass'
        'passing-validation'

    if $location && $location.search() && $location.search().loan_num
      $scope.loan_number = $location.search().loan_num
      $scope.getLoan()

]
