window.Validation ||= {}
window.Validation.FlowResultInfo = class FlowResultInfo
  constructor: (options) ->
    this.name = options.name
    this.title = options.title
    this.captions = [].concat options.captions
    this.def_path = options.def_path
    this.showCaption = false
    this.visible = true
    this.reset()

  reset: ->
    this.status = null
    this.loading = true
    this.warnings = []
    this.errors = []

  format_conclusion: (conclusion) ->
    if conclusion == 0
      @conclusion = "0"
    else
      @conclusion = conclusion

  handle_response: (p) ->
    p.then ((response) =>
      this.response = response.data
      this.format_conclusion this.response.conclusion

      this.errors = response.data.errors
      this.warnings = (response.data.warnings || [])
      
      this.status = this.determineStatus()
      this.loading = false
    ), (error) =>
      this.status = "fail"
      this.loading = false
      this.error_response = error.statusText
      
  latestEventIsUncleared = (message) ->
    latest_event = message.history[0]
    latest_event == undefined || latest_event.action != 'Cleared'

  has_active_warnings: ->
    _.any this.warnings, latestEventIsUncleared
      
  has_active_errors: ->
    _.any this.errors, latestEventIsUncleared

  determineStatus: ->
    return "fail" if this.has_active_errors()
    return "review" if this.has_active_warnings()
    "pass"

  run: ($http, loan_number, event_id, source) =>
    p = $http.get "/decisionator_flows/validations.json?id=#{loan_number}&flow=#{@name}&event_id=#{event_id}&validation_type=#{source}"
    this.handle_response p

window.Validation.PerformUnderwriterValidations = class PerformUnderwriterValidations extends FlowResultInfo
  constructor: ->
    super({name: 'ruby_rules', title: "Ruby Rules"})
    this.visible = false

  run: ($http, loan_number, event_id, source) =>
    p = $http.get "/underwriter/validations/process_validations.json?id=#{loan_number}&event_id=#{event_id}"
    this.handle_response p

  handle_response: (promise) =>
    promise.then ((response) =>
      this.response = response.data
      this.errors = response.data.errors
      this.warnings = response.data.warnings
      this.status = this.determineStatus()
      this.format_conclusion this.status
      this.loading = false
    ), (error) =>
      this.status = "fail"
      this.loading = false
      this.error_response = error.statusText

window.Validation.RegistrationChecklistResult = class RegistrationChecklistResult extends FlowResultInfo
  constructor: (checklistService) ->
    super({name: 'registration_checklist', title: "Registration Checklist", captions: "Is the Registration Checklist completed for this loan?"})
    @checklistService = checklistService
    @errors = []
    checklistService.whenChecklistLoads (cl) => this.interpretChecklist(cl)

  run: ->
    p = @checklistService.getChecklist()
    this.handle_response p

  handle_response: (promise) =>
    promise.then ((response) =>
      @loading = false
    ), (error) =>
      @status = "fail"
      @loading = false
      @error_response = error.statusText

  interpretChecklist: (checklist) ->
    @warnings = checklist.warnings
    @status = checklist.conclusion.status
    this.format_conclusion checklist.conclusion.conclusion

window.Validation.ClosingChecklistResult = class ClosingChecklistResult extends FlowResultInfo
  constructor: (checklistService) ->
    super({name: 'closing_checklist', title: "Closing Checklist", captions: "Is the Closing Checklist completed for this loan?" })
    @checklistService = checklistService
    @errors = []
    checklistService.whenChecklistLoads (cl) => this.interpretChecklist(cl)

  run: ->
    p = @checklistService.getChecklist()
    this.handle_response p

  handle_response: (promise) =>
    promise.then ((response) =>
      @loading = false
    ), (error) =>
      @status = "fail"
      @loading = false
      @error_response = error.statusText

  interpretChecklist: (checklist) ->
    @warnings = checklist.warnings
    @status = checklist.status
    @skip_to_unanswered = checklist.conclusion == "Incomplete"
    @unanswered_count = _.flatten(_.map(checklist.sections, (s) -> _.filter(s.questions, (q) -> q.answer == null && q.visible && !q.optional))).length
    this.format_conclusion checklist.conclusion


window.Validation.SettlementAgentAuditResult = class SettlementAgentAuditResult extends FlowResultInfo
  constructor: (auditService) ->
    super({name: 'settlement_agent_audit', title: "Settlement Agent Audit", captions: "Determines if the audit has been completed on the loan."})
    @auditService = auditService
    @errors = []

  run: ->
    p = @auditService.getAudit()
    p.then (response) =>
      @loading = false
      this.interpretAudit(response.data)
    p.catch (error) =>
      @status = "fail"
      @loading = false

  interpretAudit: (audit) ->
    @status = audit.conclusion.status
    this.format_conclusion audit.conclusion.conclusion

window.Validation.PerformDataCompare = class PerformDataCompare extends FlowResultInfo
  constructor: ->
    super({name: "data_compare", title: "Data Compare", captions: "Determines if 23 various fields match between the lock screen and the 1003."})
    @loadedCallbacks = []

  run: ($http, loan_number, event_id, source) ->
    p = $http.get "/data_compare/#{loan_number}?event_id=#{event_id}"
    this.handle_response p

  handle_response: (promise) =>
    promise.then ((response) =>
      @data_compare = response.data
      @errors = response.data.errors
      @status = this.determineStatus()
      this.format_conclusion response.data.conclusion || @status
      @loading = false
      this.loaded()
    ), (error) =>
      this.status = "fail"
      this.loading = false
      this.error_response = error.statusText

  whenLoaded: (callback) ->
    @loadedCallbacks.push callback

  loaded: ->
    _.each @loadedCallbacks, (callback) => callback(@data_compare)

