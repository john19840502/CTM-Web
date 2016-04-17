class DatabaseRailway < ActiveRecord::Base
  self.abstract_class = true

  # TODO - turn on model level security and get it working - Hans
  # using_access_control

  # establish_connection "#{Rails.env}_railway"

  include AutomaticallyIncludable

  #def self.table_name_prefix
  #  TABLE_NAME_PREFIX
  #end

  #####
  # This block of methods is for delayed_job_coordination
  #####
  def ensure_sentinel
    self.sentinel = Sentinel.create if self.sentinel(true).nil?
  end

  def destroy_sentinel
    self.sentinel.destroy
  end

  def increment_sentinel_counter(val = 1)
    self.ensure_sentinel
    self.sentinel(true).update_attribute(:counter, self.sentinel.counter + val)
    self.sentinel(true).counter
  end

  def decrement_sentinel_counter
    self.increment_sentinel_counter(-1)
  end

  def sentinel_counter(val = nil)
    if val.is_a? Numeric
      self.increment_sentinel_counter(val)
    else
      self.sentinel(true).counter
    end
  end


  #####
  # Global Scopes - note that they may not work on all models
  # THESE DO NOT WORK IN JOINS, since the table_name is not included in the query.
  # http://stackoverflow.com/questions/3829174/hacking-activerecord-add-global-named-scope
  # TODO - check that link, and see if it can be made to work - Hans
  #####
  # scope :active, where(:is_active => true)
  # scope :inactive, where(:is_active => false)
  # scope :as_list, order(:position)

end