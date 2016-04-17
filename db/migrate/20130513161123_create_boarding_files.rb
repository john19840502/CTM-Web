class CreateBoardingFiles < ActiveRecord::Migration
  def change
    create_table :boarding_files do |t|
      t.string     :name

      t.string      :bundle_file_name
      t.string      :bundle_content_type
      t.integer     :bundle_file_size
      t.datetime    :bundle_updated_at
      t.string      :bundle_fingerprint

      t.string      :uuid
      t.timestamps
    end
  end
end
