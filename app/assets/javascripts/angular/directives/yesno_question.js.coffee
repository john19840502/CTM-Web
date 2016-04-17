app = angular.module('yesno-question-directive', [])
app.directive "yesnoQuestion", ->
  restrict: "A"
  replace: true
  transclude: true
  scope:
    answer: '='
  controller: ($scope) ->
  templateUrl: "yesno_question.html"

