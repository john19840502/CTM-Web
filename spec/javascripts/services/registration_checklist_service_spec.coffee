describe 'RegistrationChecklistService', ->
  c = null

  beforeEach module 'registrationChecklistService'

  beforeEach inject (_$httpBackend_, $http, _$q_, _$rootScope_) ->
    this.$rootScope = _$rootScope_
    this.$httpBackend = _$httpBackend_
    this.$q = _$q_
    c = new Services.RegistrationChecklistService $http, _$q_

  afterEach ->
    this.$httpBackend.verifyNoOutstandingExpectation()
    this.$httpBackend.verifyNoOutstandingRequest()

  describe 'inject', ->
    it "should be injectable", inject ($injector)->
      service = $injector.get 'RegistrationChecklistService'
      expect(service).not.toBeNull()
  
  describe "getChecklist", ->
    stuff = { a: 'hi' }

    describe "when the loan number has not been set", ->
      it "should throw an exception", ->
        expect( -> c.getChecklist() ).toThrow("loan number missing")

    describe "when the loan number has been seet", ->
      beforeEach -> c.loanNumber = 999

      it "should resolve after the server returns", ->
        this.$httpBackend.whenGET("/registration/checklists/999").respond(stuff)
        callback = jasmine.createSpy 'callback'
        c.getChecklist().then callback
        expect(callback).not.toHaveBeenCalled()
        this.$httpBackend.flush()
        expect(callback).toHaveBeenCalled()

      it "should reject if the server request fails", ->
        this.$httpBackend.whenGET("/registration/checklists/999").respond(500, "error")
        callback = jasmine.createSpy 'callback'
        c.getChecklist().catch callback
        expect(callback).not.toHaveBeenCalled()
        this.$httpBackend.flush()
        expect(callback).toHaveBeenCalled()

      it "should keep a copy of the checklist", ->
        this.$httpBackend.whenGET("/registration/checklists/999").respond(stuff)
        p = c.getChecklist()
        this.$httpBackend.flush()
        called = false
        p.then ->
          called = true
          expect(c.checklist).toEqual stuff
        this.$rootScope.$digest()
        expect(called).toEqual true

      it "should show an error conclusion if the request fails", ->
        this.$httpBackend.whenGET("/registration/checklists/999").respond(500, {message: "error"})
        c.getChecklist()
        this.$httpBackend.flush()
        expect(c.checklist.conclusion).toEqual {  error_response: 'error', status: 'fail'}


  describe "saveAnswer", ->
    describe "when the loan number has not been set", ->
      it "should throw an exception", ->
        expect( -> c.saveAnswer() ).toThrow("loan number missing")

    describe "when the loan number has been set", ->
      beforeEach ->
        c.checklist = { thing: 'hi' }
        c.loanNumber = 123

      it "should post it back to the server and resolve on success", ->
        callback = jasmine.createSpy 'callback'
        h = this.$httpBackend.expectPUT "/registration/checklists/123", { name: "theName", answer: "theAnswer"}
        h.respond {}
        c.saveAnswer("theName", "theAnswer").then callback
        expect(callback).not.toHaveBeenCalled()
        this.$httpBackend.flush()
        expect(callback).toHaveBeenCalled()


      it "should reject if the server call fails", ->
        callback = jasmine.createSpy 'callback'
        h = this.$httpBackend.expectPUT "/registration/checklists/123", {name: 'name', answer: 'answer'}
        h.respond 500, {}
        c.saveAnswer('name', 'answer').catch callback
        expect(callback).not.toHaveBeenCalled()
        this.$httpBackend.flush()
        expect(callback).toHaveBeenCalled()

