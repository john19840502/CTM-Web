class AddForeclosureAndPaidInFullToMersImports < ActiveRecord::Migration
  def change
    add_column :mers_imports, :foreclosure_complete, :text
    add_column :mers_imports, :paid_in_full, :text
  end
end
