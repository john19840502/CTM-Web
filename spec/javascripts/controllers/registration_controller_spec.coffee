
describe "Controller: RegistrationValidationCtrl", ->
  scope = undefined

  beforeEach module "registrationValidationController"
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    $controller("RegistrationValidationCtrl", { $scope: scope })

  # all the tests that were here previously are obsolete
