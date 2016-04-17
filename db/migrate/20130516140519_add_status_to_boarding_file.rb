class AddStatusToBoardingFile < ActiveRecord::Migration
  def change
    add_column :boarding_files, :job_status_id, :integer
  end
end
