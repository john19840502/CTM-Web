class CtmExecs < DatabaseRailway
#  attr_accessible :first_name, :last_name, :middle_initial, :uuid

  def full_name
    "#{first_name} #{last_name}"
  end

  def first
    "#{first_name}"
  end

  def last
    "#{last_name}"
  end

  def to_s
    full_name
  end
end
