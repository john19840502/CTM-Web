app = angular.module('registration-checklist-directive', ['registrationChecklistService'])
app.directive "registrationChecklist", ->
  restrict: "E"
  scope:
    loan_number: "=loanNumber"

  templateUrl: "registration_checklist.html"
  controller: RegistrationChecklistDirectiveCtrl
  controllerAs: 'ctrl'
  
class RegistrationChecklistDirectiveCtrl
  constructor: ($rootScope, $scope, $http, checklistService) ->
    this.$rootScope = $rootScope
    this.$scope = $scope
    this.$http = $http
    this.checklistService = checklistService

    $scope.loading = true
    $scope.sections = []
 
    checklistService.whenChecklistLoads (cl) =>
      this.loadChecklist(cl)

  startChecklist: ->
    this.$scope.loading_new_checklist = true
    this.$scope.new_checklist_error = null
    p = this.checklistService.createNewChecklist()
    p.then (response) =>
      this.loadChecklist(response.data)
      this.$scope.loading_new_checklist = false
    p.catch (e) =>
      this.$scope.new_checklist_error = e.data.message
      this.$scope.loading_new_checklist = false


  loadChecklist: (checklist) ->
    this.$scope.started = checklist.started
    this.$scope.loading = false
    this.$scope.sections = checklist.sections
    @sections = checklist.sections
    @questions = _.flatten _.map @sections, (s) -> s.questions
    this.formatAnswers()

  displayThisMessage: (q) ->
    return false unless q.display_message_on
    return false if q.answer != q.display_message_on["value"]
    true


  questionIsVisible: (q) ->
    return true unless q.conditional_on
    other = this.findQuestion q.conditional_on.name
    if other == undefined
      q.error = "could not find question '#{q.conditional_on.name}', which this is conditional on"
      return true

    return false unless this.questionIsVisible(other)

    if q.conditional_on.presence == true
      !!other.answer
    else if q.conditional_on.equals
      other.answer == q.conditional_on.equals
    else if q.conditional_on.one_of
      $.inArray(other.answer, q.conditional_on.one_of) >= 0
    else
      q.error = "unrecognized conditional expression '#{JSON.stringify q.conditional_on}'"
      return true

  visibleQuestions: (section) ->
    _.select section.questions, (q) => this.questionIsVisible(q)

  saveValue: (name, value) ->
    q = this.findQuestion name
    q.loading = true
    q.error = null
    
    if q.input_type == 'money' && q.answer
      q.answer = $.getFormattedCurrency(value)
      value = q.answer

    p = this.checklistService.saveAnswer name, value
    p.then -> q.loading = false
    p.catch (e) ->
      q.loading = false
      q.error = e.data.message

  validateZipCode: (name, value) ->
    if (/^\d{5}(-\d{4})?$/.test(value))
      this.saveValue(name, value)
    else
      q = this.findQuestion name
      q.error = "Enter valid zip code"

  formatAnswers: ->
    this.formatCurrencyValues()
    this.formatThreePercentages()

  formatCurrencyValues: ->
    moneyQuestions = _.select @questions, (q) -> q.input_type == 'money' && q.answer
    _.each moneyQuestions, (q) ->
      q.answer = $.getFormattedCurrency(q.answer)

  three_pct_regex = /([0-9.]*) *\/ *([0-9.]*) *\/ *([0-9.]*)/
  formatThreePercentages: ->
    threeQuestions = _.select @questions, (q) -> q.input_type == 'three_percentages' && q.answer
    _.each threeQuestions, (q) ->
      matches = q.answer.match three_pct_regex
      q.percentages = _.map matches.slice(1,4), (pct) ->
        parseFloat(pct).toPrecision(4)
      
  savePercentage: (name) ->
    q = this.findQuestion name
    q.answer = (q.percentages || []).join "/"
    this.saveValue name, q.answer

  findQuestion: (name) ->
    _.find @questions, (o) -> o.name == name


RegistrationChecklistDirectiveCtrl.$inject = [ "$rootScope", "$scope", "$http", 'RegistrationChecklistService' ]
window.RegistrationChecklistDirectiveCtrl = RegistrationChecklistDirectiveCtrl
