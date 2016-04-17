require 'spec_helper'

describe Servicing::BoardingFilesHelper do

  describe "other_boarding_files" do

    let(:loan) { Struct.new(:boarding_files).new([]) }
    let(:bf) { Object.new }

    it "should say 'Not previously sent' if there are no boarding files" do
      helper.other_boarding_files(loan, bf).should == 'Not previously sent'
    end

    it "should say 'Not previously sent' if the only boarding file is the current one" do
      loan.boarding_files = [ bf ]
      helper.other_boarding_files(loan, bf).should == 'Not previously sent'
    end

    it "should link to the other files when there are other boarding files" do
      a = BoardingFile.create! name: 'foo'
      b = BoardingFile.create! name: 'bar'
      loan.boarding_files = [ bf, a, b ]
      output = helper.other_boarding_files(loan, bf)
      output.should include(servicing_boarding_file_path(a))
      output.should include(servicing_boarding_file_path(b))
    end
  end
end
