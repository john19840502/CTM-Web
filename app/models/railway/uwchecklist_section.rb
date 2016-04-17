class UwchecklistSection < DatabaseRailway
  include ChecklistDisplayConditions
  
  has_many :uwchecklist_items, :dependent => :destroy#, :order => [:position], 
  acts_as_list
  
  scope :active, ->{ where(:is_active => true) }
  scope :as_list, ->{ order(:position) }
  
  def checklist_items_count
    uwchecklist_items.size
  end
  
  def body_size_estimation_count
    words_per_line = 60
    body.length / words_per_line rescue 0
  end
  
  def length
    checklist_items_count + body_size_estimation_count
  end
  
  class << self
    def for_page(number)
      where :page => number
    end
    
    def column_1
      for_column(1)
    end
    
    def column_2
      for_column(2)
    end
    
    def for_column(number)
      where :column => number
    end
    
    def length
      UwchecklistSection.all.inject(0){|sum, cl| sum += cl.length}
    end
    
    def balance_columns
      transaction do
        # Clear out the current columns
        UwchecklistSection.update_all(:column => nil)
        
        count = 0
        halfway = UwchecklistSection.length/2 # Yay for duck typing!
        
        # Go through each section assigning column 1, until we hit the halfway point of 
        # items and body totals. Then, switch to column 2 for the rest
        for section in UwchecklistSection.as_list.active.for_page(2)
          count += section.length
          column = count < halfway ? 1 : 2
          section.update_attributes({:column => column}, without_protection: true)
        end
      end # transaction
    end
    alias :balance :balance_columns
    
  end #class methods
end




