class DatabaseDatamart < ActiveRecord::Base
  self.abstract_class = true

  include AutomaticallyIncludable

  def self.primary_key
    'id'
  end

  #TODO it is obviously horrible to have all this code in both database_datamart_readonly and here

  def self.sqlserver
    scripts = []
    scripts << sqlserver_drop_view if table_exists?
    scripts << sqlserver_base_create + sqlserver_create_view if sqlserver_create_view
    scripts
  end

  def self.sqlserver_base_create
    sql = <<-eos
    CREATE VIEW [%TABLENAME%]
    AS
    eos
    sql.gsub('%TABLENAME%', table_name)
  end

  def self.sqlserver_drop_view
    sql = <<-eos
      DROP VIEW vw_myView
    eos
    sql.gsub('vw_myView', self.table_name)
  end

  # This should be overridden in the child classes to include the SQLServer code to build up the view.
  def self.sqlserver_create_view
    false
  end
end