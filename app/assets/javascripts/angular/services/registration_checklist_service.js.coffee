window.Services ||= {}
class window.Services.RegistrationChecklistService
  constructor: ($http, $q) ->
    this.$http = $http
    this.$q = $q
    this.checklist = null
    this.loanNumber = undefined
    @loadCallbacks = []

  getChecklist: ->
    throw "loan number missing" unless this.loanNumber
    p = this.$http.get "/registration/checklists/#{this.loanNumber}"
    p.success (response) =>
      this.checklist = response
      this.checklistLoaded()
    p.error (response) =>
      this.checklist = { conclusion: { status: 'fail', error_response: response.message } }

  createNewChecklist: ->
    p = this.$http.post "/registration/checklists/#{this.loanNumber}"
    p.success (response) =>
      this.checkList = response

  saveAnswer: (name, answer) ->
    throw "loan number missing" unless this.loanNumber
    this.$http.put "/registration/checklists/#{this.loanNumber}", {name: name, answer: answer}

  whenChecklistLoads: (callback) ->
    @loadCallbacks.push callback

  checklistLoaded: ->
    _.each @loadCallbacks, (callback) => callback(@checklist)

Services.RegistrationChecklistService.$inject = ['$http', '$q']
app = angular.module('registrationChecklistService', [])
app.service 'RegistrationChecklistService', Services.RegistrationChecklistService
