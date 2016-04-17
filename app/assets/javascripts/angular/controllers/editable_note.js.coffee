editNoteController = angular.module('editNoteController', ['xeditable'])
editNoteController.run ["editableOptions", (editableOptions) ->
  editableOptions.theme = "bs3"
  return
]
editNoteController.controller 'editNoteCtrl', [
  "$scope"
  "$http"
  ($scope, $http) ->

    $scope.editNoteData = ->
      $http.post("/edit_notes/editnote.json?notes=" + encodeURIComponent($scope.editing_note) + "&note_type=" + $scope.validation_type).then ((response) ->
        if response
          $scope.get_note_data()
      )

    $scope.get_note_data  = ->
      $http.get("/edit_notes/getnote.json?note_type=" + $scope.validation_type).then (response) ->
        $scope.can_edit_notes()
        if response.data
          $scope.editing_note = response.data.join('|')
          $scope.notes = response.data
        else
          $scope.notes = ""

    $scope.can_edit_notes = ->
      return $http.get("/edit_notes/can_edit.json").then ((response) ->
        $scope.manage = response.data
      )

    $scope.get_note_data()  

]
