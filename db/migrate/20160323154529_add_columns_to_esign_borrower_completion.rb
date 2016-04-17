class AddColumnsToEsignBorrowerCompletion < ActiveRecord::Migration
  def change
    add_column :esign_borrower_completions, :assignee, :string
    add_column :esign_borrower_completions, :status, :string
  end
end
