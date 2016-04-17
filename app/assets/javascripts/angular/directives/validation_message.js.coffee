app = angular.module('validation-message-directive', [])
app.directive "validationMessage", ->
  restrict: "E"
  scope:
    message: "=message"
    message_type: "=messageType"
    loan_number: "=loanNumber"
    validation_type: "=validationType"
    
  templateUrl: "validation_message.html"
  controller: ValidationMessageDirectiveCtrl
  controllerAs: 'ctrl'
  
class ValidationMessageDirectiveCtrl
  constructor: ($rootScope, $scope, $http) ->
    this.$rootScope = $rootScope
    this.$scope = $scope
    this.$http = $http
    this.showMessage $scope.message

    $scope.setFlag = (warning) ->
      return false if $scope.is_reviewed(warning)
      $http.post('/' + $scope.validation_type + '/validations/process_validation_alert.json?lid=' + $scope.loan_number + '&rid=' + warning[0]).then (response) ->
        warning[2] = response.data
      $rootScope.$emit 'ValidationWarningProcessed'

  toggleHistory: ->
    @showHistory = !@showHistory
  
  toggleForm: ->
    @showForm = !@showForm

  showMessage: (message) ->
    $scope = this.$scope
    @message = message

    @showForm = false
    @flagClass = 'red_flag'
    @alertClass =
      if this.$scope.message_type == 'error'
        'alert-error'
      else
        ''

    @last_action = null
    @formSubmissionPending = false
    @formReason = null

    _.each message.history, (h) -> h.action = "Cleared" unless h.action

    @last_action = message.history[0]
    if @last_action
      @showHistoryLink = (message.history.length > 1)
      @showHistory = false
      @historyCount = message.history.length - 1
      @other_actions = message.history.slice(1)
      if @last_action.action == "Cleared"
        @flagClass = 'green_flag'
        @alertClass = 'alert-success'

    if @last_action && (@last_action.action == "Cleared")
      @next_action = "Reinstate"
    else
      @next_action = "Clear"

    @formActionLabel = "#{@next_action} this #{$scope.message_type}?"

  submitForm: ->
    @formSubmissionPending = true
    @errorMessage = null
    p = this.$http.post "/validation_alerts/#{@next_action.toLowerCase()}",
      loan_id: this.$scope.loan_number
      rule_id: @message.rule_id
      text: @message.text
      alert_type: this.$scope.validation_type
      reason: @formReason

    p.success (response) =>
      @message.history.unshift response
      this.showMessage @message
      this.$rootScope.$emit 'ValidationWarningProcessed'

    p.error (response) =>
      @formSubmissionPending = false
      @errorMessage = response.message


ValidationMessageDirectiveCtrl.$inject = [ "$rootScope", "$scope", "$http" ]
window.ValidationMessageDirectiveCtrl = ValidationMessageDirectiveCtrl
