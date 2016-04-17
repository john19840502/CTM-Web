class EscrowAgent < ActiveRecord::Base
	has_many :settlement_agent_audits
  has_many :settlement_agent_trid_audits

	validates_as_postal_code :zip_code, :country => "US", :multiline => true,  :message => "is blank or invalid."

	validates_length_of :state, :minimum => 2, :maximum => 2, :allow_blank => true, :message => "should be 2 character length."
end
