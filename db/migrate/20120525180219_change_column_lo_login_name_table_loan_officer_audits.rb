class ChangeColumnLoLoginNameTableLoanOfficerAudits < ActiveRecord::Migration
  def up
    remove_column :loan_officer_audits, :lo_login_name
    add_column :loan_officer_audits, :datamart_user_id, :integer
  end

  def down
    add_column :loan_officer_audits, :lo_login_name, :string
    remove_column :loan_officer_audits, :datamart_user_id
  end
end
