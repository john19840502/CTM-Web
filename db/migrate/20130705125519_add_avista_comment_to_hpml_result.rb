class AddAvistaCommentToHpmlResult < ActiveRecord::Migration
  def change
    add_column :hpml_results, :avista_comment, :boolean
  end
end
