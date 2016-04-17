window.Services ||= {}
class window.Services.SettlementAgentAuditService
  constructor: ($http, $q) ->
    this.$http = $http
    this.$q = $q
    this.audit = null
    this.loanNumber = undefined

  getAudit: ->
    throw "Loan number missing" unless this.loanNumber
    p = this.$http.get "/closing/settlement_agent_audits/last_audit.json?id=#{this.loanNumber}"
    p.success (response) ->
      this.audit        = response    
    p.error (response) ->
      this.audit = {conclustion: {status: 'fail', error_response: response.message}}

  getEscrow: (escrow_id) ->
    throw "No Escrow for this Audit" unless escrow_id
    p = this.$http.get "/escrow_agents/#{escrow_id}.json"
    p.success (response) ->
      this.escrow = response
    p.error (e) -> e

  saveAudit: (audit, trid_loan) ->
    audit['trid_loan'] = trid_loan
    p = this.$http.post('/closing/settlement_agent_audits.json', audit)
    p.success (response) -> this.audit = response
    p.error (e) -> e

  saveEscrow: (escrow) ->
    p = this.$http.post('/escrow_agents.json', escrow)
    p.success (response) ->
      this.escrow = response
    p.error (e) -> e

  validate_audit: (audit) ->
    p = this.$http.post('/closing/settlement_agent_audits/get_conclusion.json', audit)
    p.success (response) -> response
    p.error (e) -> e

  isTeamLead: ->
    p = this.$http.get "/closing/settlement_agent_audits/is_closing_lead.json"
    p.success (response) -> response
    p.error (e) -> throw "Could not validate team lead"


Services.SettlementAgentAuditService.$inject = ['$http', '$q']
app = angular.module('settlementAgentAuditService', [])
app.service 'SettlementAgentAuditService', Services.SettlementAgentAuditService