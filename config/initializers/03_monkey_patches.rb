###################################
# Monkey Patches
#
# This is a set of patches Hans has written to add functionality to the core
# rails/ruby stack that come in handy.
#
###################################

# Debugging methods
# These next methods are logging helper methods
def caller_method_name
    parse_caller(caller(2).first).last
end

def parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
        file = Regexp.last_match[1]
		line = Regexp.last_match[2].to_i
		method = Regexp.last_match[3]
		[file, line, method]
	end
end

def log_this(message, level='debug')
  output = <<-eom
##########################################
#
#

#{message}

--------------------------------------

Called from: #{caller_method_name}

#
#
##########################################
eom
  
  logger.send(level, output)
end


#####
# General Methods
#####
def days_between(date1, date2)
  ((date1 - date2)/86400).to_i
end


#####
# Class extensions
#####

class Object
   def zilch?  
     # (self.respond_to?(:empty?) ? self.empty? : (!self.is_a?(Numeric) and (self.respond_to?(:blank?)) ? self.blank?)) and (self.nil? or self ==)
     self.nil? or self == 0.0 or (self.respond_to?(:empty?) ? self.empty? : false) or (self.respond_to?(:blank?) ? self.blank? : false)
   end
end

class NilClass
  # Mimic the strip class from string, to get rid of those pesky 
  # nil errors when we try to do string operations on a nil
  def strip
   nil
  end
end

#module ActiveRecord
#  class Base
#    #def self.random
#    #  if (c = count) != 0
#    #    find(:first, :offset =>rand(c))
#    #  end
#    #end
#
#  #   def self.select(order=:id)
#  #     self.all(:order => order).map { |model| [model.name, model.id]}
#  #   end
#  #
#  #   def self.all_polymorphic_types(name)
#  #     @poly_hash ||= {}.tap do |hash|
#  #       Dir.glob(File.join(Rails.root, "app", "models", "**", "*.rb")).each do |file|
#  #         klass = (File.basename(file, ".rb").camelize.constantize rescue nil)
#  #         next if klass.nil? or !klass.ancestors.include?(ActiveRecord::Base)
#  #         klass.reflect_on_all_associations(:has_many).select{|r| r.options[:as] }.each do |reflection|
#  #           (hash[reflection.options[:as]] ||= []) << klass
#  #         end
#  #       end
#  #     end
#  #     @poly_hash[name.to_sym]
#  #   end
#  end
#end

class Hashit
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})
    end
  end

  def save
    hash_to_return = {}
    self.instance_variables.each do |var|
      hash_to_return[var.gsub("@","")] = self.instance_variable_get(var)
    end
    return hash_to_return
  end
end

# Make arrays of symbols sortable
class Symbol
  include Comparable

  def <=>(other)
    self.to_s <=> other.to_s
  end
end

class Numeric
  
  # takes a number and options hash and outputs a string in any currency format
  def to_currency(options={})
    number = self
    # :currency_before => false puts the currency symbol after the number
    # default format: $12,345,678.90
    options = {:currency_symbol => "$", :delimiter => ",", :decimal_symbol => ".", :currency_before => true, :no_decimal => false}.merge(options)
    
    # split integer and fractional parts 
    int, frac = ("%.2f" % number).split('.')
    # insert the delimiters
    int.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{options[:delimiter]}")
    
    if options[:no_decimal]
      frac_part = ""
    else
      frac_part = options[:decimal_symbol] + frac
    end
    
    if options[:currency_before]
      options[:currency_symbol] + int + frac_part
    else
      int + frac_part + options[:currency_symbol]
    end
  end
  
  
  def to_years_and_months
    case 
    when self == 0
      "0 months"
    when self < 12
      "#{ self} month#{ self == 1 ? '' : 's' }"
    when self == 12
      "1 year"
    when self > 12
      years = self / 12
      months = self % 12
      if (months > 0)
        "#{years} year#{ years > 1 ? 's' : '' } and #{ months} month#{ months == 1 ? '' : 's' }"
      else
        "#{years} year#{ years > 1 ? 's' : '' }"
      end
    end
  end

  def roundup(nearest=10)
    self % nearest == 0 ? self : self + nearest - (self % nearest)
  end

  def rounddown(nearest=10)
    self % nearest == 0 ? self : self - (self % nearest)
  end
  
  def roundnearest(nearest=10)
    up = roundup(nearest)
    down = rounddown(nearest)
    if (up-self) < (self-down)
      return up
    else
      return down
    end
  end
  
  def factorial
    my_i = self.to_i
    if my_i <= 0
      result = 0
    else 
      result = 1
      my_i.downto(2) do |n|
        result = result * n
      end
    end
    result
  end
  
  def to_zero
    self < 0 ? 0 : self
  end
# end

# http://www.hans-eric.com/code-samples/ruby-floating-point-round-off/
# class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end

  def ceil_to(x)
    (self * 10**x).ceil.to_f / 10**x
  end

  def floor_to(x)
    (self * 10**x).floor.to_f / 10**x
  end
  
  def to_dollars
    '$' + sprintf("%.2f", self).to_s
  end
end

class String
  # Return the last n characters of a string
  #def last(n)
  #  self[-n,n]
  #end
  
  # unicode_str.initial_caps => new_str
  # returns a copy of a string with initial capitals
  # "Jules-Édouard".initial_caps => "J.É."
  def initial_caps
    self.tr('-', ' ').split(' ').map { |word| word.chars.first.upcase.to_s + "." }.join
  end
  
  def capitalize_each_word
    self.downcase.gsub(/^[a-z]|\s+[a-z]/) { |a| a.upcase }
  end
  
  def compress
    self.gsub(' ','')
  end
  
  def truncate_words(length = 10, end_string = ' ...')
    words = self.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end  
  
  def chunk_by_words(chunk_size = 8)
    result = []
    words = self.split
    for chunk in words.in_groups_of(chunk_size)
      result << chunk.join(' ')
    end
    result
  end
  
  def chunk_by_length(max_length = 40)
    result = []
    words = self.split
    line = ''
    for word in words
      if (line.length > max_length) or (line.length + word.length > max_length)
        result << line
        line = ''
      end
      line << ' ' + word 
    end
    result << line
    result
  end
  
  def String.random_alphanumeric(length=6)
    chars  = ['A'..'Z','0'..'9'].map{|r|r.to_a}.flatten
    ignore = ['0','1','L','A','E','I','O','U']
    valid = (chars - ignore)
    Array.new(length).map{valid[rand(valid.size)]}.join.downcase
  end
  
  def asset_escape
    CGI::escape(self.downcase.downcase.gsub(/\s+/,'_').gsub(/[^[:alnum:]_]/, ''))
  end
  
  def transliterate
    # Based on permalink_fu by Rick Olsen

    # Escape str by transliterating to UTF-8 with Iconv
    s = Iconv.iconv('ascii//ignore//translit', 'utf-8', self).to_s

    # Downcase string
    s.downcase!

    # Remove apostrophes so isn't changes to isnt
    s.gsub!(/'/, '')

    # Replace any non-letter or non-number character with a space
    s.gsub!(/[^A-Za-z0-9]+/, ' ')

    # Remove spaces from beginning and end of string
    s.strip!

    # Replace groups of spaces with single hyphen
    s.gsub!(/\ +/, '-')
  end
end

# Weighted random methods for Array
class Array
  # Chooses a random array element from the receiver based on the weights
  # provided. If _weights_ is nil, then each element is weighed equally.
  # 
  #   [1,2,3].random          #=> 2
  #   [1,2,3].random          #=> 1
  #   [1,2,3].random          #=> 3
  #
  # If _weights_ is an array, then each element of the receiver gets its
  # weight from the corresponding element of _weights_. Notice that it
  # favors the element with the highest weight.
  #
  #   [1,2,3].random([1,4,1]) #=> 2
  #   [1,2,3].random([1,4,1]) #=> 1
  #   [1,2,3].random([1,4,1]) #=> 2
  #   [1,2,3].random([1,4,1]) #=> 2
  #   [1,2,3].random([1,4,1]) #=> 3
  #
  # If _weights_ is a symbol, the weight array is constructed by calling
  # the appropriate method on each array element in turn. Notice that
  # it favors the longer word when using :length.
  #
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "hippopotamus"
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "dog"
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "hippopotamus"
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "hippopotamus"
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "cat"
  def random(weights=nil)
    return random(map {|n| n.send(weights)}) if weights.is_a? Symbol
    
    weights ||= Array.new(length, 1.0)
    total = weights.inject(0.0) {|t,w| t+w}
    point = Kernel.rand * total
    
    zip(weights).each do |n,w|
      return n if w >= point
      point -= w
    end
  end
  
  # Generates a permutation of the receiver based on _weights_ as in
  # Array#random. Notice that it favors the element with the highest
  # weight.
  #
  #   [1,2,3].randomize           #=> [2,1,3]
  #   [1,2,3].randomize           #=> [1,3,2]
  #   [1,2,3].randomize([1,4,1])  #=> [2,1,3]
  #   [1,2,3].randomize([1,4,1])  #=> [2,3,1]
  #   [1,2,3].randomize([1,4,1])  #=> [1,2,3]
  #   [1,2,3].randomize([1,4,1])  #=> [2,3,1]
  #   [1,2,3].randomize([1,4,1])  #=> [3,2,1]
  #   [1,2,3].randomize([1,4,1])  #=> [2,1,3]
  def randomize(weights=nil)
    return randomize(map {|n| n.send(weights)}) if weights.is_a? Symbol
    
    weights = weights.nil? ? Array.new(length, 1.0) : weights.dup
    
    # pick out elements until there are none left
    list, result = self.dup, []
    until list.empty?
      # pick an element
      result << list.random(weights)
      # remove the element from the temporary list and its weight
      weights.delete_at(list.index(result.last))
      list.delete result.last
    end
    
    result
  end

  def includes_any? array
    self.any? {|g| array.include?(g)}
  end

  def includes_none? array
    !self.any? {|g| array.include?(g)}
  end

  def includes_all? array
    self.all? {|g| array.include?(g)}
  end

  def includes_some_but_not_all? array
    !self.includes_all?(array) and self.includes_any?(array)
  end
end

def days_in_month(year, month)
  (Date.new(year, 12, 31) << (12-month)).day
end

def days_in_current_month
  days_in_month(Time.now.year, Time.now.month)
end
alias :days_in_this_month :days_in_current_month


# Ruby 2.3 introduced an issue where OpenStructs serialized to yaml 
# cannot unserialize themselves.  We do that in e.g. Tss::LoanPrice which 
# serializes its loan_details as an OpenStruct.  Hopefully we will be
# able to remove this monkeypatch in a future ruby release. 
# See https://github.com/tenderlove/psych/issues/263
class OpenStruct
  class << self
    alias allocate new
  end
end
