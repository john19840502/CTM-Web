underwriterValidationController = angular.module('underwriterValidationController', ['hide-element-directive', 'validation-results-directive', 'flow-result-directive', 'processValidationsService', 'flowService', 'flowAdderService'])

underwriterValidationController.controller 'UwValidationCtrl', [
  "$rootScope"
  "$scope"
  "$http"
  "$q"
  "$location"
  "ProcessValidationsService"
  "FlowService"
  "AddFlow"
  ($rootScope, $scope, $http, $q, $location, ProcessValidationsService, FlowService, AddFlow) ->

    $scope.getLoan = ->
      resetLoan()

      fetchLoan = $http.get("/underwriter/validations/search.json?id=" + $scope.loan_number )

      fetchLoan.then ((response) ->
        $scope.loading_loan = false
        $scope.loan = response.data.loan
        $scope.manual_fact_types = response.data.loan.manual_fact_types
        $scope.texasitems        = [ 'Yes' , 'No'  ]
        $scope.brokerTexas       = response.data.loan.broker_texas_only
        $scope.texas_indicator   = response.data.loan.texas_only
        $scope.property_state    = response.data.loan.property_state
        # if _.all($scope.manual_fact_types, (ft) -> !!ft.value)
            
        if !$scope.texasRequiredForValidations()
          $scope.performValidations()

      ), (error) ->
        $scope.loading_loan = false
        $scope.loan_not_found = true

    underwriter_specific = [
      new Validation.PerformUnderwriterValidations
    ]
    $scope.info_flows = AddFlow.adder('info_underwriter')
    $scope.normal_flows = AddFlow.adder('underwriter').concat underwriter_specific

    all_flows = $scope.info_flows.concat $scope.normal_flows

    $scope.visibleFlows = ->
      _.filter $scope.normal_flows, (f) -> f.visible

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

    $scope.texasOnly = (texas_indicator) ->
      $scope.loading_texas_only = true

      stuff = {
        manual_fact_types: { "texas_only": texas_indicator}
      }
      p = $http.post("/manual_fact_types/#{$scope.loan_number}/save", stuff)
      p.then ((response) ->
        $scope.loading_texas_only   = false
        $scope.error_saving_message = null
        $scope.texas_indicator      = response.data[0].value
        $scope.performValidations()
        ), (error) ->
          $scope.loading_texas_only = false
          $scope.error_saving_message = error.data.error

    resetLoan = ->
      $scope.loan = null
      $scope.loan_not_found = false
      $scope.loading_loan = true
      resetValidations()

    resetValidations = ->
      $scope.warnings = []
      $scope.errors = []
      $scope.loading_validation_flag = true
      $scope.validation_status = null
      $scope.texas_required_flag = false
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

    $scope.runValidations = (button) ->
      $http.get("/underwriter/validations/search.json?id=" + $scope.loan_number ).then ((response) -> 
        $scope.loan = response.data.loan
        $scope.performValidations()
      ), (error) ->
        $scope.loan = null
        $scope.loan_not_found = true

    $scope.texasRequiredForValidations = ->
      if $scope.loan.property_state == 'TX' && $scope.loan.purpose_type == 'Refinance' && $scope.texas_indicator == undefined
        true
      else
        false
    
    $scope.performValidations = () ->
      if $scope.texasRequiredForValidations()
        $scope.texas_required_flag = true
        return

      resetValidations()
      event = $http.get("/decisionator_flows/create_new_event.json?id=" + $scope.loan_number + "&validation_type=underwriter" )

      event.then (response) ->
        $scope.event_id = response.data.id

        promises = _.map all_flows, (f) ->
          p = f.run $http, $scope.loan_number, $scope.event_id , 'underwriter'
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
