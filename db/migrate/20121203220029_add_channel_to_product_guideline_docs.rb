class AddChannelToProductGuidelineDocs < ActiveRecord::Migration
  def change
    add_column :product_guideline_docs, :channel, :string
  end
end
