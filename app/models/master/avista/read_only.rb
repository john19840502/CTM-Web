module Master
  module Avista
    class ReadOnly < ActiveRecord::Base
      self.abstract_class = true

      def self.primary_key
        'id'
      end

      #include AutomaticallyIncludable

      # Prevent the creation of new records and modifications to existing records
      def readonly?
        true
      end

      def before_destroy
        raise_read_only
      end

      def before_save
        raise_read_only
      end

      def raise_read_only
        raise ActiveRecord::ReadOnlyRecord
      end

      def self.run_script(sql)
        connection.execute(sql)
      end

      def self.master_classes
        Dir.glob("#{Rails.root}/app/models/master/**/*.rb").each { |file| require file }
        self.descendants
      end

      def self.print_sqlserver_scripts
        run_model_scripts(false)
      end

      def self.run_sqlserver_scripts
        puts "Loading scripts..."
        run_model_scripts
      end

      def self.run_model_scripts(affect_database = true)
        # Run the scripts from each datamart file
        master_classes.each do |klass|
          next if klass.abstract_class?

          scripts = klass.sqlserver

          puts "\n\n**********************"
          puts "*** EXECUTING #{klass}"
          puts '***'

          puts scripts

          if affect_database
            scripts.each{|script| run_script(script)}
          end

          puts "\n***\n**********************"
        end
      end

      def self.sqlserver
        scripts = []
        scripts << sqlserver_drop_view if table_exists?
        scripts << sqlserver_base_create + sqlserver_create_view if sqlserver_create_view
        scripts << sqlserver_refresh_view if table_exists?
        scripts
      end

      def self.sqlserver_refresh_view
        sql = <<-eos
          EXEC sp_refreshview vw_myView
        eos
        sql.gsub('vw_myView', self.table_name)
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
  end
end