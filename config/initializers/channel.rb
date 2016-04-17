class Channel
  attr_accessor :name, :identifier, :abbreviation

  def initialize(name, identifier, abbreviation = nil)
    self.name = name
    self.identifier = identifier
    self.abbreviation = abbreviation || identifier[0,2]
  end

  def to_s
    "Channel #{name}: #{identifier}"
  end

  @@retail = Channel.new('Retail', 'A0-Affiliate Standard')
  def self.retail
    @@retail
  end

  @@consumer_direct = Channel.new('Consumer Direct', 'C0-Consumer Direct Standard')
  def self.consumer_direct
    @@consumer_direct
  end

  @@private_banking = Channel.new('Private Banking', 'P0-Private Banking Standard')
  def self.private_banking
    @@private_banking
  end

  @@wholesale = Channel.new('Wholesale', 'W0-Wholesale Standard')
  def self.wholesale
    @@wholesale
  end

  @@reimbursement = Channel.new('Reimbursement', 'R0-Reimbursement Standard')
  def self.reimbursement
    @@reimbursement
  end
  def self.mini_corr; reimbursement; end

  def self.all
    [ retail, consumer_direct, private_banking, wholesale, reimbursement ]
  end

  def self.retail_all_ids
    [ retail, consumer_direct, private_banking ].map(&:identifier)
  end

  def self.non_retail_ids
    [ wholesale, reimbursement ].map(&:identifier)
  end
end
