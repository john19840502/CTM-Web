class AddUseExistingSurveyToInitialDisclosureValidation < ActiveRecord::Migration
  def change
    add_column :initial_disclosure_validations, :use_existing_survey, :string
  end
end
