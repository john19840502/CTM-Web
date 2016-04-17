module AutomaticallyIncludable
  def self.included(base)
    # base.before_validation_on_create :assign_uuid
    base.before_validation(:assign_uuid, :on => :create)
  end
  
  def assign_uuid
    if self.respond_to? :uuid and self.uuid.blank?
      self.uuid = UUIDTools::UUID.random_create.to_s #.gsub('-','')
    end
  end
end
