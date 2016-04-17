class AddColumnsToFundingModeler < ActiveRecord::Migration
  def change
    add_column :funding_modelers, :ny_mtg_tax, :string
    add_column :funding_modelers, :lender_credit, :string
    add_column :funding_modelers, :premium_price, :string
    add_column :funding_modelers, :broker_comp_lndr_pd, :string
    add_column :funding_modelers, :credit_to_cure, :string
    add_column :funding_modelers, :mip_refund, :string
    add_column :funding_modelers, :ctm_admin_whls, :string
    add_column :funding_modelers, :credit_report, :string
    add_column :funding_modelers, :va_fund_fee, :string
    add_column :funding_modelers, :escrow_holdback, :string
  end
end
