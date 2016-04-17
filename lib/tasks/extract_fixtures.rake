task :extract_fixtures => :environment do
  sql  = "SELECT * FROM %s"
  skip_tables = ["schema_info"]
  ActiveRecord::Base.establish_connection
  if (not ENV['TABLES'])
    tables = ActiveRecord::Base.connection.tables - skip_tables
  else
    tables = ENV['TABLES'].split(/, */)
  end
  if (not ENV['OUTPUT_DIR'])
    output_dir="#{RAILS_ROOT}/test/fixtures"
  else
    output_dir = ENV['OUTPUT_DIR'].sub(/\/$/, '')
  end
  (tables).each do |table_name|
    i = "000"
    File.open("#{output_dir}/#{table_name}.yml", 'w') do |file|
      data = ActiveRecord::Base.connection.select_all(sql % table_name)
      file.write data.inject({}) { |hash, record|
        hash["#{table_name}_#{i.succ!}"] = record
        hash
      }.to_yaml
      puts "wrote #{table_name} to #{output_dir}/"
    end
  end
end

task :jj_extract_fixtures => :environment do
  sql  = "SELECT * FROM %s"
  skip_tables = ["schema_info", "mers_exports", "mers_orgs"]
  ActiveRecord::Base.establish_connection
  if (not ENV['TABLES'])
    views = %w(loans)
    tables = ActiveRecord::Base.connection.tables - skip_tables + views
  else
    tables = ENV['TABLES'].split(/, */)
  end
  class_names = tables.map { |table_name| table_name.classify }
  if (not ENV['OUTPUT_DIR'])
    output_dir="#{Rails.root}/test/fixtures"
  else
    output_dir = ENV['OUTPUT_DIR'].sub(/\/$/, '')
  end
  (class_names).each do |class_name|
    class_constant = class_name.constantize rescue nil
    table_name = class_name.tableize
    if class_constant
      i = "000"
      File.open("#{output_dir}/#{table_name}.yml", 'w') do |file|
        data = class_constant.limit(100) #We don't need the whole database, just a decent sample
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record.attributes
          hash
        }.to_yaml
        puts "wrote #{table_name} to #{output_dir}/"
      end
    end
  end
end
