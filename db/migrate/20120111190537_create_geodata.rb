class CreateGeodata < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string      :abbreviation
      t.string      :name
      t.decimal     :lat, :precision => 15, :scale => 10
      t.decimal     :lon, :precision => 15, :scale => 10
      t.integer     :fips
      t.string      :uuid
      t.timestamps
    end
    
    add_index :states, :abbreviation
    add_index :states, :name
    add_index :states, :fips
    add_index :states, :uuid
    
    create_table :counties do |t|
      t.string      :name
      t.references  :state
      t.decimal     :lat, :precision => 15, :scale => 10
      t.decimal     :lon, :precision => 15, :scale => 10
      t.integer     :county_fips
      t.integer     :fips
      t.string      :uuid
      t.timestamps
    end
    
    add_index :counties, :name
    add_index :counties, :fips
    add_index :counties, :uuid
    
    create_table :cities do |t|
      t.string      :name
      t.references  :state
      t.references  :county
      t.decimal     :lat, :precision => 15, :scale => 10
      t.decimal     :lon, :precision => 15, :scale => 10
      t.integer     :city_fips
      t.integer     :fips, :limit => 8
      t.integer     :elevation_in_feet
      t.integer     :pop_1990
      t.integer     :pop_2000
      t.integer     :gnis_id
      t.string      :uuid
      t.timestamps
    end
    
    add_index :cities, :state_id
    add_index :cities, :county_id
    add_index :cities, :name
    add_index :cities, :fips
    add_index :cities, :uuid
    
  end
end
