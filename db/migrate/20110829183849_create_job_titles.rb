class CreateJobTitles < ActiveRecord::Migration
  def self.up
    create_table :job_titles do |t|
      t.string      :name
      t.string      :uuid
      t.references  :department
      t.timestamps
    end
    
    add_index :job_titles, :name
    add_index :job_titles, :uuid
    add_index :job_titles, :department_id
  end

  def self.down
    drop_table :job_titles
  end
end
