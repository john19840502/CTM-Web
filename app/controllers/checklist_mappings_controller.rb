class ChecklistMappingsController < ApplicationController
  def index
    @closing_questions = ClosingChecklistDefinition.questions
  end
end
