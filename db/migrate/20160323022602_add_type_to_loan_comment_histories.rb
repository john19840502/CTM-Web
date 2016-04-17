class AddTypeToLoanCommentHistories < ActiveRecord::Migration
  def up
    add_column :loan_comment_histories, :type, :string
    add_column :loan_comment_histories, :loan_num, :string
    remove_column :loan_comment_histories, :forced_registration_id
  end

  def down
    remove_column :loan_comment_histories, :type
    remove_column :loan_comment_histories, :loan_num
    add_column :loan_comment_histories, :forced_registration_id, :integer
  end
end
