
describe "validationResults", ->
  $rootScope = $scope = $httpBackend = ctrl = null

  beforeEach module 'validation-results-directive'
  beforeEach inject ($http, _$httpBackend_) ->
    $rootScope = {}
    $scope = {}
    $scope.errors = []
    $scope.warnings = []
    $scope.loan_number = '1234567'
    $scope.validation_type = 'registration'
    $httpBackend = _$httpBackend_
    ctrl = new ValidationResultsDirectiveCtrl($rootScope, $scope, $http)
    
  describe 'is_reviewed', ->
    it "is_reviewed should be true for truthy stuff", ->
      warning = [null, null, 'truthy']
      expect($scope.is_reviewed(warning)).toEqual true

    it "is_reviewed should be false for falsy stuff", ->
      warning = [null, null, null]
      expect($scope.is_reviewed(warning)).toEqual false

    it "is_not_reviewed should be false for truthy stuff", ->
      warning = [null, null, 'truthy']
      expect($scope.is_not_reviewed(warning)).toEqual false

    it "is_not_reviewed should be true for falsy stuff", ->
      warning = [null, null, null]
      expect($scope.is_not_reviewed(warning)).toEqual true

  describe 'get_user_name', ->
    it "should return the user name from warning[2]", ->
      warning = [null, null, {user_name: 'fred'}]
      expect($scope.get_user_name(warning)).toEqual 'fred'

    it "should not break if warning[2] is missing", ->
      warning = [null, null]
      expect($scope.get_user_name(warning)).toBeUndefined()

  describe 'get_created_at', ->
    it "should return created_at from warning[2]", ->
      warning = [null, null, {created_at: 'fred'}]
      expect($scope.get_created_at(warning)).toEqual 'fred'

    it "should not break if warning[2] is missing", ->
      warning = [null, null]
      expect($scope.get_created_at(warning)).toBeUndefined()


  describe 'setFlag', ->

    beforeEach ->
      $rootScope.$emit = jasmine.createSpy 'emit'

    describe 'when it is reviewed', ->
      warning = [ 123, null, { user_name: 'fred' }]
      it "should not do anything if it is already reviewed", ->
        $scope.setFlag(warning)
        expect($rootScope.$emit).not.toHaveBeenCalled()

    describe 'when it is not reviewed', ->
      warning = null
      data = { user_name: 'john' }
      beforeEach ->
        warning = [999, null, null]
        $httpBackend.expectPOST('/registration/validations/process_validation_alert.json?lid=1234567&rid=999').respond data

      it "should post and update the warning with response data", ->
        $scope.setFlag(warning)
        $httpBackend.flush()
        expect(warning[2]).toEqual data

      it "should emit an event on $rootScope", ->
        $scope.setFlag(warning)
        $httpBackend.flush()
        expect($rootScope.$emit).toHaveBeenCalledWith('ValidationWarningProcessed')


  describe 'uniqueErrors', ->
    it "should get only the unique error messages from the errors list", ->
      $scope.errors.push 'foo'
      $scope.errors.push 'foo'
      $scope.errors.push 'bar'
      expect($scope.uniqueErrors()).toEqual ['foo', 'bar']

