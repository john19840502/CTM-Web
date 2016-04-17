require 'digest/md5'
module CTM
  module MSSqlView
    attr_accessor :fields

    ############## Set the path and allow overrides. ##############
    @@dbo_path = 'LENDER_LOAN_SERVICE.dbo'

    def current_path
      @@dbo_path
    end

    def path_override(new_path)
      @@dbo_path = new_path
    end

    ############## Field & Join Definitions ##############
    def field(field_name, options = {})
      # from column, force type or raise error, default value
      add_field(field_name, options)
    end

    def field_list(list_of_fields, options = {})
      list_of_fields.each do |f|
        field_name = !options[:coerce] ? f : f.to_s.underscore
        # remove column for field list as it wont work, then merge
        # the other possible options.
        options.delete(:column)
        options.merge!({column: f})
        add_field(field_name, options)
      end
    end

    def join(from_table, options = {})
      raise error 'You must provide a string or an array of 2 items for on:' unless options[:on].present?
      raise error 'from must be set before setting a join!' unless @from_alias.present?
      if options[:on].kind_of?(String)
        options[:on] = ["#{@from_alias}.#{options[:on]}", "#{options[:as]}.#{options[:on]}"]
      elsif options[:on].kind_of?(Array)
        raise error 'You must provide 2 items for on:' if options[:on].size != 2
      end
      add_join(from_table, options)
    end

    def from(primary_table, options = {})
      add_from(primary_table, options)
    end

    def build_query
      "SELECT #{select_text} FROM #{@from_table} #{join_text}"
    end


    ############## PRIVATE METHODS ##############

    def select_text
      select_items.join(', ')
    end
    private :select_text

    def join_text
      Array(build_join).join(' ')
    end
    private :join_text

    def error(msg)
      Exception.new(msg)
    end
    private :error

    def parse_field_options(options)
      available_options = [:source, :column, :as, :type, :default]
      parse_options(available_options, options)
    end
    private :parse_field_options

    def parse_join_options(options)
      available_options = [:on, :type, :as, :and]
      parse_options(available_options, options)
    end
    private :parse_join_options

    def parse_from_options(options)
      available_options = [:as]
      parse_options(available_options, options)
    end
    private :parse_from_options

    def parse_options(available_options, options)
      formatted_options = {}
      options.keys.each do |k,v|
        if available_options.include?(k.to_sym)
          formatted_options[k.to_sym] = options[k]
        end
      end
      formatted_options
    end
    private :parse_options

    def add_field(field_name, options)
      raise error 'from must be set before setting a field!' unless @from_alias.present?
      @fields = Hash.new if @fields.nil?
      options = parse_field_options(options)

      # #p options
      # @fields.each do |f, h|
      #   if h[:column] == options[:column] && h[:source] == options[:source]
      #     source = h[:source].present? ? h[:source] : @from_alias
      #     raise ArgumentError.new("#{h[:column]} already defined on #{source}.")
      #   end
      # end

      options.reverse_merge!(default_options(field_name))

      @fields[field_name.to_sym] = options if field_name.present?
    end
    private :add_field

    def default_options(field_name)
      {column: field_name.to_s.camelize}
    end

    def add_join(join_table, options)
      @joins = Hash.new if @joins.nil?
      options = parse_join_options(options).merge({table_name: join_table})
      string = options.map {|k,v| "#{k}:#{v}"}.flatten.join(",")
      key = Digest::MD5.hexdigest("#{string}")
      @joins[key] = options if join_table.present?
    end
    private :add_join

    def add_from(primary_table, options)
      @from_alias = options[:as].present? ? options[:as] : ''
      primary_table_name(primary_table, options)
    end
    private :add_from

    def primary_table_name(primary_table, options)
      @from_table = "#{current_path}.[#{primary_table}]"
      @from_table += " AS #{options[:as]}" if options[:as].present?
    end
    private :primary_table_name

    def select_items
      select_items  = []
      if @fields.present? && @fields.length > 0
        @fields.each do |k, v|
          source_table = v[:source].present? ? v[:source] : @from_alias
          select_items << "#{source_table}.#{v[:column]} AS #{k}"
        end
        select_items
      else
        raise error 'You must set at least one field.'
      end
    end
    private :select_items

    def build_join
      join_items    = []
      if @joins.present? && @joins.length > 0
        @joins.each do |key, join|
          join_string = ''
          if join[:type].present?
            position = join[:type].to_s.downcase.scan(/(right|left)/)[0]
            join_string += "#{position[0].upcase} " if position.present?
            side = join[:type].to_s.downcase.scan(/(inner|outer)/)[0]
            join_string += "#{side[0].upcase} JOIN" if side.present?
          end
          join_string += " #{current_path}.[#{join[:table_name].to_s}]"
          join_string += " AS #{join[:as].to_s}" if join[:as].present?
          join_string += " ON #{join[:on][0]} = #{join[:on][1]}" if join[:on].present?

          # handle the ands on the joins
          if join[:and].present?
            if join[:and].respond_to?('each')
              join[:and].each do |k,val|
                sql_alias = join[:as].to_s if join[:as].present?
                join_string += " AND [#{sql_alias}].[#{k}] = '#{val}'"
              end
            else
              sql_alias = join[:as].to_s if join[:as].present?
              k = join[:and]
              join_string += " AND [#{sql_alias}].[#{k}] = [#{@from_alias}].#{k}"
            end
          end
          join_items << join_string
        end


        join_items
      end
    end
    private :build_join
  end
end
