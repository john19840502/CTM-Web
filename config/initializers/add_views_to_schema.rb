# By default, Rails does not add the views in to the schema, but they are essential for our purposes.
# Most of this code is just the Rails default from https://github.com/rails/rails/blob/master/activerecord/lib/active_record/schema_dumper.rb
# It should be updated when Rails is updated

ActiveRecord::SchemaDumper.class_eval do
  def tables(stream)
    # STUFF ADDED FOR CTM-WEB
    tables_and_views = @connection.tables + @connection.views
    tables_and_views.keep_if {|t| t.starts_with?('ctmweb_') && t.ends_with?('_development') }
    tables_and_views.sort.each do |tbl|
    # /STUFF ADDED FOR CTM-WEB
      next if ['schema_migrations', ignore_tables].flatten.any? do |ignored|
        case ignored
          when String; tbl == ignored
          when Regexp; tbl =~ ignored
          else
            raise StandardError, 'ActiveRecord::SchemaDumper.ignore_tables accepts an array of String and / or Regexp values.'
        end
      end
      table(tbl, stream)
    end
  end
end
