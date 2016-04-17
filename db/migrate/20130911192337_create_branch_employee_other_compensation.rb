class CreateBranchEmployeeOtherCompensation < ActiveRecord::Migration
  def change
    create_table :branch_employee_other_compensations do |t|
      t.integer  :datamart_user_id
      t.date     :effective_date
      t.decimal  :bsm_override,              :precision => 6, :scale => 2
      t.decimal  :per_loan_processed,        :precision => 6, :scale => 2
      t.decimal  :per_loan_branch_processed, :precision => 6, :scale => 2

      t.timestamps

    end

    add_index :branch_employee_other_compensations, :datamart_user_id
    add_index :branch_employee_other_compensations, :effective_date

    DatamartUserCompensationPlan.all.each do |u|
      br = BranchEmployeeOtherCompensation.new(
        datamart_user_id: u.datamart_user_id,
        effective_date: u.effective_date,
        bsm_override: u.bsm_override,
        per_loan_processed: u.per_loan_processed,
        per_loan_branch_processed: u.per_loan_branch_processed
      )
      br.save(validate: false)
    end

    remove_column :datamart_user_compensation_plans, :bsm_override
    remove_column :datamart_user_compensation_plans, :per_loan_processed
    remove_column :datamart_user_compensation_plans, :per_loan_branch_processed
  end
end
