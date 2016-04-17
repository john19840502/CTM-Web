# == Schema Information
#
# Table name: ctmweb_hud_lines_development
#
#  id                :integer          not null, primary key
#  loan_general_id   :integer
#  hud_type          :string(5)
#  line_num          :integer
#  sys_fee_name      :string(100)
#  user_def_fee_name :string(50)
#  rate_perc         :decimal(8, 4)
#  additional_amt    :decimal(, )
#  num_days          :integer
#  daily_amt         :decimal(, )
#  num_months        :integer
#  monthly_amt       :decimal(, )
#  total_amt         :decimal(, )
#

require 'spec_helper'

describe HudLine do

  describe "class methods" do
    let(:loan) { Loan.find_by_id(7446201) }
    subject { loan.hud_lines }

    specify { subject.hud_line_value('Origination Fee').should == 0.0 }

    specify { subject.hud_line_value_pre_trid(801, 'Origination Fee').should == 0.0 }

    specify { subject.hud_map_value(1109..1119).should == 228.0 }

    specify { subject.hud_ary_value([1202], %w(Mortgage Releases Deed)).should == 130.0 }


    describe "paid_by_borrower_only" do

      # This test is kind of broken; really needs to be written for non-read-only models instead.  
      xit "should not crash if there aren't any" do
        fees = PaidByFee.new({paid_by_type: "Lender", pay_amount: 123}, without_protection: true)
        huds = [ HudLine.new(paid_by_fees: fees, without_protection: true)]
        expect(HudLine.paid_by_borrower_only(huds)).to eq 0.0
      end
    end
  end

end
