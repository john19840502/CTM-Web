class AddColumnsToRegistrationChecklists < ActiveRecord::Migration
  def change
    add_column :registration_checklists, :recvd_intent_to_proceed, :string
    add_column :registration_checklists, :sspl_uploaded, :string
    add_column :registration_checklists, :is_1003_complete, :string
    add_column :registration_checklists, :credit_docs_uploaded, :string
  end
end
