class CreateMersBiennialReviews < ActiveRecord::Migration
  def change
    create_table :mers_biennial_reviews do |t|
      t.string      :name
      t.string      :status, :default => 'created'  # For state machine
      t.string      :bundle_file_name
      t.string      :bundle_content_type
      t.integer     :bundle_file_size
      t.datetime    :bundle_updated_at
      t.string      :bundle_fingerprint
      t.boolean     :is_recompare
      t.string      :recompare_file_name
      t.string      :recompare_content_type
      t.integer     :recompare_file_size
      t.datetime    :recompare_updated_at
      t.string      :recompare_fingerprint
      t.text        :errorz
      t.text        :processed
      t.timestamps
    end

    add_index :mers_biennial_reviews, :name
    add_index :mers_biennial_reviews, :is_recompare
    add_index :mers_biennial_reviews, :created_at
    add_index :mers_biennial_reviews, :bundle_file_name
    add_index :mers_biennial_reviews, :recompare_file_name
  end
end
