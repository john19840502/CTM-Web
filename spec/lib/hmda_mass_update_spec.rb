require 'spec_helper'
require 'hmda_mass_update'

describe Compliance::Hmda::HmdaMassUpdate do
	let(:loan_general) { LoanGeneral.new }

  HEADERS = "APLNNO,APR\n"

  let(:sample_data) do
  	{ :aplnno=>"1111111", :apr=>"1.234" }
  end

  let(:sample_input) do
    CSV.generate do |csv|
      csv << HEADERS.strip.split(',')
      csv << sample_data.values
    end
  end

  let!(:event) { LoanComplianceEvent.create(aplnno: 1111111, apr: "2") }

  describe "mass_update" do
    before do
      ActiveRecord::Base.current_user_proc = nil
      foo = LoanComplianceEvent.where(id: event.id)
      LoanComplianceEvent.stub(:unexported).and_return(foo)
      foo.stub(:where).and_return(foo)
      foo.stub(:update_all).and_return(nil)
      event.stub(:record_changes)
    end

  	it "should mass update loan compliance event if headers match" do
  		header = "apr"
  		Compliance::Hmda::HmdaMassUpdate.new(sample_input, header).mass_update
  		event.reload
  		event[:apr].should == "1.234"
  	end

  	it "should raise exception if headers do not match" do
  		header = "preappr"
  		lambda { Compliance::Hmda::HmdaMassUpdate.new(sample_input, header).mass_update }.should raise_exception(StandardError) 
  	end

  end
end

