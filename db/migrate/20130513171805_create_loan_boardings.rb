class CreateLoanBoardings < ActiveRecord::Migration
  def change
    create_table :loan_boardings do |t|
      t.references :loan
      t.references :boarding_file

      t.timestamps
    end
  end
end
