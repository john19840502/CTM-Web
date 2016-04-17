class RenameForcedRegistrationComments < ActiveRecord::Migration
  def up
    rename_table :forced_registration_comments, :loan_comment_histories
  end

  def down
    rename_table :loan_comment_histories, :forced_registration_comments
  end
end
