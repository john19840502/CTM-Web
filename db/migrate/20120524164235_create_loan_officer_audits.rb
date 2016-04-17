class CreateLoanOfficerAudits < ActiveRecord::Migration
  def change
    create_table :loan_officer_audits do |t|
      t.string :loan_id, limit: 50
      t.string :lo_login_name, limit: 50
      t.integer :loan_event_id
      t.datetime :event_date

      t.timestamps
    end

    add_index :loan_officer_audits, :event_date
    add_index :loan_officer_audits, :loan_id
    add_index :loan_officer_audits, [:lo_login_name, :event_date]
  end
end
