app = angular.module('hide-element-directive', [])

app.directive "hideElement", ()  ->
  restrict: "A"
  link: ($scope, element, attrs) ->
    label = attrs.hiddenLabel || "Show Field"

    element.html("<span class='passive-link'>" + label + "</span>")

    element.on 'mouseenter', ->
      element.html("<span>" + attrs.hiddenValue + "</span>")

    element.on 'mouseleave', ->
      element.html("<span class='passive-link'>" + label + "</span>")
