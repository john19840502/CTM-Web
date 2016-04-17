closingValidationController = angular.module('closingValidationController', ['hide-element-directive', 'validation-results-directive', 'flow-thingy-result-directive', 'flow-result-directive', 'flowService', 'flowAdderService', 'settlement-agent-directive', 'settlementAgentAuditService', 'closing-checklist-directive'])

closingValidationController.controller 'ClosingValidationCtrl', [
  "$rootScope"
  "$scope"
  "$http"
  "$q"
  "$location"
  "FlowService"
  "AddFlow"
  "ClosingChecklistService"
  "SettlementAgentAuditService"
  ($rootScope, $scope, $http, $q, $location, FlowService, AddFlow, checklistService, auditService) ->

    $scope.getLoan = ->
      resetLoan()

      fetchLoan = $http.get("/closing/validations/search.json?id=" + $scope.loan_number )

      fetchLoan.then ((response) ->
        checklistService.loanNumber = $scope.loan_number
        auditService.loanNumber = $scope.loan_number
        $scope.loading_loan = false
        $scope.load_audit = false
        $scope.loan = response.data.loan
        # console.info($scope.loan)

        $scope.manual_fact_types = response.data.loan.manual_fact_types
        # if _.all($scope.manual_fact_types, (ft) -> !!ft.value)
        $scope.performValidations()
    
        $scope.by_closer        = response.data.loan.delayed_by
        $scope.delay_date       = response.data.loan.delay_date
        
        $scope.show_cd_only     = $scope.loan.disclose_by.cd_only

        $scope.texas_indicator   = response.data.loan.texas_only
        $scope.displayOnlyTexas  = true
        $scope.property_state    = response.data.loan.property_state
      ), (error) ->
        $scope.loading_loan = false
        $scope.loan_not_found = true

    resetLoan = ->
      $scope.loan = null
      $scope.loan_not_found = false
      $scope.loading_loan = true
      $scope.originalValues = {}
      $scope.saving = {}
      $scope.error_saving = {}
      resetValidations()

    $scope.info_flows = AddFlow.adder('info_closing')
    $scope.normal_flows = AddFlow.adder('closing').concat [
      new Validation.ClosingChecklistResult(checklistService)
      new Validation.SettlementAgentAuditResult(auditService)
    ]

    all_flows = $scope.info_flows.concat $scope.normal_flows
    
    # this is dumb, is there a better way?
    data_compare = _.find all_flows, (f) -> f.name == "data_compare"
    data_compare.whenLoaded (dc) ->
      $scope.data_compare = dc
 
    resetValidations = ->
      $scope.warnings = []
      $scope.errors = []
      $scope.loading_validation_flag = true
      $scope.validation_status = null
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

    $rootScope.$on 'SettlementAgentProcessed',(event, audit_obj ) ->
      settlement_agent = all_flows.filter((obj) ->
        obj.name == "settlement_agent_audit"
      ) 
      prev_conclusion = settlement_agent[0].conclusion
      new_conclusion = settlement_agent[0].interpretAudit(audit_obj)
      if new_conclusion != prev_conclusion
        $rootScope.$emit 'ValidationWarningProcessed'
      
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

      event = $http.get("/decisionator_flows/create_new_event.json?id=" + $scope.loan_number + "&validation_type=closing" )

      event.then  ((response) ->
        $scope.event_id = response.data.id

        promises = _.map all_flows, (f) ->
          p = f.run $http, $scope.loan_number, $scope.event_id, 'closing'
          p.then ->
            addMesssagesTo $scope.warnings, f.warnings
            addMesssagesTo $scope.errors, f.errors

        $q.all(promises).then ->
          $scope.validation_status = determineOverallStatus()
          $scope.loading_validation_flag = false
      )

    $scope.requestCD = ->
      reqCD = $http.get("/closing/validations/" + $scope.loan_number + "/set_cd_only.json" )

      reqCD.then ((response) ->
        $scope.disclose_by      = response.data.disclose_by
        $scope.show_cd_only     = $scope.disclose_by.cd_only
      ), (error) ->
        alert error

    $scope.rightDelay = (delay_date) ->
      $scope.loading_date = true
      stuff = {
        manual_fact_types: { "right_to_delay": delay_date}
      }
      p = $http.post("/manual_fact_types/#{$scope.loan_number}/save", stuff)
      p.then ((response) ->
          $scope.loading_date = false
          $scope.error_saving_message = null
          $scope.by_closer = _.find(response.data, (ft) -> ft.name == "right_to_delay").user_name
        ), (error) ->
          $scope.loading_date = false
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
        ), (error) ->
          $scope.loading_texas_only = false
          $scope.error_saving_message = error.data.error

    $scope.cashToClose = (cash_to_close, total_cash_to_close) ->
      $scope.loading_cash_to_close = true
      stuff = {
        manual_fact_types: { "cash_to_close": cash_to_close}
      }
      p = $http.post("/manual_fact_types/#{$scope.loan_number}/save", stuff)
      p.then ((response) ->
        $scope.loading_cash_to_close = false
        $scope.error_saving_cash_to_close = null
        ), (error) ->
          $scope.loading_cash_to_close = false
          $scope.error_saving_cash_to_close = error.data.message


    $scope.setClass = (flow_status) ->
      if flow_status == 'fail'
        'failing-validation'
      else if flow_status == 'pass'
        'passing-validation'

    $scope.storeOrigValue = (name, value) ->
      $scope.originalValues[name] = value

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


    $scope.second_closer_name_options = [ "Fish, Leah", "Hazel, Timothy", "Montagne, Michelle",
             "Smith, Lisa", "Welch, Judi", "Wilson, Lenelle" ]

    if $location && $location.search() && $location.search().loan_num
      $scope.loan_number = $location.search().loan_num
      $scope.getLoan()

]

