class AddValidationStatusToLoanValidationEvent < ActiveRecord::Migration
  def up
    add_column :loan_validation_events, :validation_status, :string, :default => "PASS"
  end

  def down
    remove_column :loan_validation_events, :validation_status, :string
  end
end
