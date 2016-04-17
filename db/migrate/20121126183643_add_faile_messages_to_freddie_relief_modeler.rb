class AddFaileMessagesToFreddieReliefModeler < ActiveRecord::Migration
  def change
    add_column :freddie_relief_modelers, :upb_perc_fail, :string
    add_column :freddie_relief_modelers, :modeler_pass_or_fail, :string
    add_column :freddie_relief_modelers, :princ_curt_fail, :string
    add_column :freddie_relief_modelers, :actual_amout_prin_fail, :string
    add_column :freddie_relief_modelers, :cash_to_borrower_fail, :string
  end
end
