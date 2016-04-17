class AddAasmStateToMersException < ActiveRecord::Migration
  def change
    add_column :mers_exceptions, :aasm_state, :string
  end
end
