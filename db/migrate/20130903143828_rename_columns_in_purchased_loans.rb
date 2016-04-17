class RenameColumnsInPurchasedLoans < ActiveRecord::Migration
  def change
    rename_column :purchased_loans, :wholesalefulldocsisavalida, :wholsalefulldocsisavalida
    rename_column :purchased_loans, :prm_borr_mail_city_ste_zip, :prm_borr_mail_cty_ste_zip
    rename_column :purchased_loans, :occupancy, :occupncy
  end
end
