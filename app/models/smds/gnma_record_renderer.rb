class Smds::GnmaRecordRenderer
 
  def self.valid_file_spec?(spec)
    spec.each { |record_type,record_spec|
#      puts record_type
#      puts record_type.length
      return false if record_type.length != 3
      record_length = 3
      record_spec.each { |field_name, field_spec| 
        fs = field_spec.split('|')
#        puts "#{field_name} : #{fs[0]} : #{fs[1]} : #{fs[2]}"
        record_length += fs[1].to_i
        record_length += 1 + fs[2].to_i unless fs[2].nil?
      }
#      puts record_length
      return false if record_length != 80
    }
    return true
  end

  def self.check_for_errors(group_spec, source, physical_records_to_exclude = [], optional_physical_records = [])
    return 'incorrect file spec!' unless valid_file_spec?(group_spec)
    records = source.is_a?(Array) ? source : [source]
    errors = ""
    records.each { |s|
      errors += render_physical_records(group_spec, s, physical_records_to_exclude, optional_physical_records, true)
    }
    return errors 
  end


  def self.render_logical_record(group_spec, source, physical_records_to_exclude = [], optional_physical_records = [])
    raise 'incorrect file spec!' unless valid_file_spec?(group_spec)
    return if source.nil?
    render_physical_records(group_spec, source, physical_records_to_exclude, optional_physical_records, false)
  end

  def self.render_logical_records(group_spec, source, physical_records_to_exclude = [], optional_physical_records = [])
    raise 'incorrect file spec!' unless valid_file_spec?(group_spec)
    raise 'expecting an array of records' unless source.is_a?(Array)
    return "" if source.size==0
    r = ""
    source.each { |s|
      r += render_physical_records(group_spec, s, physical_records_to_exclude, optional_physical_records, false)
    }
    return r 
  end

  def self.render_physical_records(group_spec, source, records_to_exclude = [], optional_records = [], error_checking = false)
    r = ""
    group_spec.each { |record_type, record_spec|
      next if records_to_exclude.include?(record_type)
      next if optional_records.include?(record_type) && record_is_empty?(source, record_spec)
      if error_checking
        r += render_record(source, record_spec, true)
      else
        r += record_type
        r += render_record(source, record_spec, false)
      end
    }
    return r
  end

  def self.record_is_empty?(source, record_spec)
#    puts ">>>>>> check for empty"
    record_spec.each { |field_name, field_spec| 
      n = field_name.to_s
      next if n.start_with?('filler')
      v = source.send(field_name)
#      puts 'nil' if v.nil?
#      puts "#{n} = |#{v}|"
      if (v.is_a? String)
        return false if v.length > 0
      else
        return false unless v.nil?
      end
    }
#    puts "empty!"
    return true
  end

  def self.render_record(source, record_spec, error_checking)
    r = ""
    errors = ""
    record_spec.each { |field_name, field_spec| 
      fs = field_spec.split('|')
      n = field_name.to_s
      if n.start_with?('filler')
        r += ' ' * fs[1].to_i
      else
        v = source.send(field_name)
        if (v.nil?)
          r += render_nil(fs[1], fs[2])
        else
          begin
            case fs[0]
            when 'X' then r += render_string_value(field_name, v, fs[1].to_i)
            when '9' then r += render_numeric_value(field_name, v, fs[1].to_i, fs[2])
            when 'D' then r += render_date_value(field_name, v)
            else raise "unexpected type: #{fs[0]}"
            end
          rescue => e
            raise e unless error_checking
            errors += "#{e.message}\n"
          end
        end
      end
    }
    return errors if error_checking
    r += "\n"
  end

  def self.render_nil(len, len2)
    length = len.to_i
    length += len2.to_i + 1 unless len2.nil?
    " " * length
  end

  def self.render_string_value(fld, val, len)
    raise "#{fld} should be a string" unless val.is_a? String
    raise "#{fld} is too long should be #{len} but is #{val.length}" unless val.length <= len
    val.ljust(len, ' ')
  end


  def self.render_numeric_value(fld, val, len, precision)
    raise "#{fld} should be a numeric" unless val.is_a? Numeric
    raise "#{fld} should be positive but is negative" unless val >= 0
    raise "#{fld} is too big should be less than #{10 ** len} but is #{val}" unless val < 10 ** len
    fmt = "%.#{precision.to_i}f"
    r = (fmt % val)
    precision.nil? ? r.rjust(len, ' ') : r.rjust(len+precision.to_i+1, ' ')
  end

  def self.render_date_value(fld, val)
    raise "#{fld} should be a date" unless ((val.is_a? Date) || (val.is_a? DateTime) || (val.is_a? Time))
    val.strftime("%Y%m%d")
  end

end