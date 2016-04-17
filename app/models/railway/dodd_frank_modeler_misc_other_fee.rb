class DoddFrankModelerMiscOtherFee <  DatabaseRailway
  belongs_to  :dodd_frank_modeler

  attr_accessible :dodd_frank_modeler_id, :amount, :description

  # validates :dodd_frank_modeler_id, :amount, :description, presence: :true
end