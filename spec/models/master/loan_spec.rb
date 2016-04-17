require 'spec_helper'

describe Master::Loan do


  it "should not have joins that increase the number of rows returned" do
    Master::Loan.where(loan_num: [ "1022358", "1053697", "1030773", "1032348", "1000052" ]).count.should == 5
  end

  describe 'scopes' do

    describe 'all_retail' do
      it "should include loans in retail" do
        id = Master::Loan.where(channel: Channel.retail.identifier).limit(1).pluck(:id).first
        Master::Loan.all_retail.find(id).should_not be nil
      end
    end
  end

  describe 'methods' do 
    let(:loan) { Master::Loan.new(purpose_type: 'Refinance') }
    it '#loan_refinance?' do 
      loan.is_refinance?.should be true
    end
    it '#is_primary_residence?' do
      loan.stub(:property_usage_type_2).and_return('PrimaryResidence')
      loan.is_primary_residence?.should be true
    end
    it '#is_fha? (true)' do 
      loan.stub(:product_name).and_return('FHAOMGHI')
      loan.is_fha?.should be true
    end
    it '#is_fha? (false)' do 
      loan.stub(:product_name).and_return('OMGHI')
      loan.is_fha?.should be false
    end

    context '#lowest_fico_score' do 
      it 'has no borrowers and no rep_fico' do 
        loan.lowest_fico_score.should be nil
      end

      it 'returns rep fico score when no borrowers' do 
        loan.stub rep_fico_score: 720
        loan.lowest_fico_score.should == 720
      end

      it 'returns lowest fico when borrowers exist' do 
        loan = Master::Loan.find(1969)
        loan.lowest_fico_score.should == 774
      end
    end

    context '#product_code_translated' do
      before do
        loan.stub(:product_code_uw).and_return('OMGHIUW')
        loan.stub(:product_name).and_return('OMGHILF')
        loan.stub(:product_code).and_return('OMGHILP')
      end

      it 'has product_code underwriting' do 
        expect(loan.product_code_translated).to eq 'OMGHIUW'
      end

      it 'has product_code underwriting' do 
        loan.stub(:product_code_uw).and_return(nil)
        expect(loan.product_code_translated).to eq 'OMGHILF'
      end

      it 'has product_code underwriting' do 
        loan.stub(:product_code_uw).and_return(nil)
        loan.stub(:product_name).and_return(nil)
        expect(loan.product_code_translated).to eq 'OMGHILP'
      end
    end

    context '#property_state_translated' do
      before do
        loan.stub(:property_state_gfe).and_return('GF')
        loan.stub(:property_state).and_return('MI')
        loan.stub(:property_state_lld).and_return('LD')
      end

      it 'has property_state gfe' do 
        expect(loan.property_state_translated).to eq 'GF'
      end

      it 'has property_state property' do 
        loan.stub(:property_state_gfe).and_return(nil)
        expect(loan.property_state_translated).to eq 'MI'
      end

      it 'has property_state LLD' do 
        loan.stub(:property_state_gfe).and_return(nil)
        loan.stub(:property_state).and_return(nil)
        expect(loan.property_state_translated).to eq 'LD'
      end
    end

    context "#is_locked?" do
      it 'is_locked?' do
        loan.stub(:locked_at).and_return(3.days.ago)
        expect(loan.is_locked?).to be true
      end

      it 'is_locked?' do
        loan.stub(:locked_at).and_return(3.days.ago)
        loan.stub(:lock_expiration_at).and_return(3.days.from_now)
        expect(loan.is_locked?).to be true
      end

      it 'not is_locked?' do
        loan.stub(:locked_at).and_return(nil)
        expect(loan.is_locked?).to be false
      end

      it 'not is_locked?' do
        loan.stub(:locked_at).and_return(3.days.ago)
        loan.stub(:lock_expiration_at).and_return(1.day.ago)
        expect(loan.is_locked?).to be false
      end
    end

  end

  describe 'set_for_boarding' do
    let(:loan) { Master::Loan.find(1969) }
    context "when there is no custom data present" do
      it "should set force_boarding true" do
        loan.set_for_boarding
        loan.custom_loan_data.should_not be_nil
        loan.custom_loan_data.force_boarding.should be true
      end
    end

    context "when there is custom data present already" do
      before do
        loan.custom_loan_data = Master::LoanDetails::CustomLoanData.new({force_boarding: false}, without_protection: true)
        loan.custom_loan_data.save!
      end

      it "should set force_boarding true" do
        loan.set_for_boarding
        loan.custom_loan_data.force_boarding.should be true
      end
    end
  end

  describe 'coborrowers' do 
    let(:loan) { Master::Loan.find(1969) }
    it 'primary_borrower' do 
      loan.primary_borrower.last_name.should == 'EVENS'
    end
    it 'secondary borrower' do 
      loan.secondary_borrower.last_name.should == 'BOSHEARS'
    end
    it 'coborrowers' do 
      loan.coborrowers.size.should == 1
      loan.coborrowers.first.last_name.should == 'DEAVER'
    end
  end

  describe 'Arms' do 
    let(:loan) { Master::Loan.new(loan_amortization_type: 'AdjustableRate') }
    it '#is_arm?' do 
      loan.is_arm?.should be true
    end
  end

  describe 'Mortgage Insurance' do
    let(:loan) { Master::Loan.where(loan_num: '1053697').first }
    context '#has_mi?' do 
      it 'non-conventional mortgage' do 
        loan.stub(:mortgage_type).and_return('Refinance')
        loan.has_mi?.should be false
      end
      it 'lender paid mi' do
        loan.stub(:lender_paid_mi).and_return('1')
        loan.has_mi?.should be true
      end

      context "when there is lender paid MI" do
        before { loan.stub lender_paid_mi: '1' }
        it "should be true even if there is no hud line" do
          loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>902}).and_return([])
          loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>1003}).and_return([])
          loan.has_mi?.should be true
        end
      end

      it 'mi certificate id' do
        loan.stub(:mi_certificate_id).and_return('2')
        loan.has_mi?.should be true
      end

      context "trid loan" do
        before {
          loan.stub(:trid_loan?).and_return(true)
        }

        context "902 hud line" do
          before { 
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance'}).and_return([])
          }

          it 'hud monthly payment' do
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance Premium'}).and_return([Master::HudLine.new(monthly_amount: 1)])
            loan.has_mi?.should be true
          end

          it 'payment amount' do 
            # needed to skip the hud line to test further.
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance Premium'}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:payment_amount).and_return(1)
            loan.has_mi?.should be true
          end

          it 'mi program' do
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance Premium'}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_program).and_return('1')
            loan.has_mi?.should be true
          end

          it 'mi company' do 
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance Premium'}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_company_id).and_return(1)
            loan.has_mi?.should be true
          end

          it 'default' do 
            loan.stub(:mortgage_type).and_return("foobar")
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance Premium'}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_company_id).and_return(0)
            loan.has_mi?.should be false
          end
        end

        context "1003 hud line" do
          before { 
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance Premium'}).and_return([])
          }

          it 'hud monthly payment' do
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance'}).and_return([Master::HudLine.new(monthly_amount: 1)])
            loan.has_mi?.should be true
          end

          it 'payment amount' do 
            # needed to skip the hud line to test further.
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance'}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:payment_amount).and_return(1)
            loan.has_mi?.should be true
          end

          it 'mi program' do
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance'}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_program).and_return('1')
            loan.has_mi?.should be true
          end

          it 'mi company' do 
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance'}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_company_id).and_return(1)
            loan.has_mi?.should be true
          end

          it 'default' do 
            loan.stub(:mortgage_type).and_return("foobar")
            loan.stub_chain(:hud_lines, :hud, :where).with({:system_fee_name=>'Mortgage Insurance'}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_company_id).and_return(0)
            loan.has_mi?.should be false
          end
        end
      end


      context "pre trid loan" do
        before {
          loan.stub(:trid_loan?).and_return(false)
        }

        context "902 hud line" do
          before { 
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>1003}).and_return([])
          }

          it 'hud monthly payment' do
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>902}).and_return([Master::HudLine.new(monthly_amount: 1)])
            loan.has_mi?.should be true
          end

          it 'payment amount' do 
            # needed to skip the hud line to test further.
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>902}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:payment_amount).and_return(1)
            loan.has_mi?.should be true
          end

          it 'mi program' do
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>902}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_program).and_return('1')
            loan.has_mi?.should be true
          end

          it 'mi company' do 
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>902}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_company_id).and_return(1)
            loan.has_mi?.should be true
          end

          it 'default' do 
            loan.stub(:mortgage_type).and_return("foobar")
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>902}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_company_id).and_return(0)
            loan.has_mi?.should be false
          end
        end

        context "1003 hud line" do
          before { 
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>902}).and_return([])
          }

          it 'hud monthly payment' do
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>1003}).and_return([Master::HudLine.new(monthly_amount: 1)])
            loan.has_mi?.should be true
          end

          it 'payment amount' do 
            # needed to skip the hud line to test further.
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>1003}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:payment_amount).and_return(1)
            loan.has_mi?.should be true
          end

          it 'mi program' do
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>1003}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_program).and_return('1')
            loan.has_mi?.should be true
          end

          it 'mi company' do 
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>1003}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_company_id).and_return(1)
            loan.has_mi?.should be true
          end

          it 'default' do 
            loan.stub(:mortgage_type).and_return("foobar")
            loan.stub_chain(:hud_lines, :hud, :where).with({:line_num=>1003}).and_return([Master::HudLine.new(monthly_amount: 0)])
            loan.stub(:mi_company_id).and_return(0)
            loan.has_mi?.should be false
          end
        end
      end
    end
  end

  describe "original_deferred_fee_amount" do
    let(:loan) { Master::Loan.new({id: 12313}, without_protection: true) }

    context "for pre trid loans" do
      before { loan.stub trid_loan?: false }

      it "should call the old sql thingy" do
        expect(loan).to receive(:original_deferred_fee_amount_pre_trid).and_return 666
        expect(loan.original_deferred_fee_amount).to eq 666
      end
    end

    context "for post trid loans" do
      before { loan.stub trid_loan?: true }

      it "should call the OriginalDeferredFeeCalculator" do
        expect(Calculator::CalculateOriginalDeferredFee).to receive(:for).with(loan).and_return 123
        expect(loan.original_deferred_fee_amount).to eq 123
      end
    end

  end


  describe ".initial_disclosure_requested_value" do

    it "should return the value for wholesale" do
      field = custom_wholesale_field_for "Y"
      subject.stub_chain("custom_fields.initial_disclosure_wholesale").and_return([field])
      subject.stub(:channel).and_return "W0-Wholesale Standard"

      expect(subject.initial_disclosure_requested_value).to eq "Y"
    end

    it "should return the value for retail" do
      field = custom_retail_field_for "Y"
      subject.stub_chain("custom_fields.initial_disclosure_retail").and_return([field])
      subject.stub(:channel).and_return "A0-Affiliate Standard"

      expect(subject.initial_disclosure_requested_value).to eq "Y"
    end

    it "should return nil if none found" do
      subject.stub_chain("custom_fields.initial_disclosure_wholesale").and_return([])
      subject.stub(:channel).and_return "W0-Wholesale Standard"

      expect(subject.initial_disclosure_requested_value).to be_nil
    end

    it "should return nil if channel is not handled" do
      subject.stub(:channel).and_return "Foo the the Bar"

      expect(subject.initial_disclosure_requested_value).to be_nil
    end

    it "should Y if any of them are Y" do
      field1 = custom_retail_field_for "Y"
      field2 = custom_retail_field_for "N"
      subject.stub_chain("custom_fields.initial_disclosure_retail").and_return([field1, field2])
      subject.stub(:channel).and_return "A0-Affiliate Standard"

      expect(subject.initial_disclosure_requested_value).to eq "Y"
    end

    it "should filter out the default value" do
      field = custom_wholesale_field_for "P"
      subject.stub_chain("custom_fields.initial_disclosure_wholesale").and_return([field])
      subject.stub(:channel).and_return "W0-Wholesale Standard"

      expect(subject.initial_disclosure_requested_value).to eq nil
    end

    def custom_wholesale_field_for value
      custom_field_for "Wholesale Initial Disclosure Request", "Ready to Request Disclosure", value
    end

    def custom_retail_field_for value
      custom_field_for "Retail Initial Disclosure Request", "RequestDisclosure", value
    end
  end

  describe "initial_disclosure_request_completed?" do

    context "retail" do
      before do
        subject.channel = Channel.retail.identifier
      end

      it "should be completed if any custom field has the right stuff" do
        subject.stub custom_fields: [
          custom_field_for("sdlkfj", "InternalUseOnly", "1/1/1900"),
          custom_field_for("Retail Initial Disclosure Request", "sdlfkjdf", "1/1/1900"),
          custom_field_for("Retail Initial Disclosure Request", "InternalUseOnly", nil),
          custom_field_for("Retail Initial Disclosure Request", "InternalUseOnly", "1/1/1900"),
        ]
        expect(subject.initial_disclosure_request_completed?).to eq true
      end

      it "should not care if there are spaces" do
        subject.stub custom_fields: [
          custom_field_for("Retail Initial Disclosure Request", "Internal Use Only", "1/1/1900"),
        ]
        expect(subject.initial_disclosure_request_completed?).to eq true
      end

      it "should not be completed if no custom field has a value for the right field" do
        subject.stub custom_fields: [
          custom_field_for("sdlkfj", "InternalUseOnly", "1/1/1900"),
          custom_field_for("Retail Initial Disclosure Request", "sdlfkjdf", "1/1/1900"),
          custom_field_for("Retail Initial Disclosure Request", "InternalUseOnly", nil),
          custom_field_for("Retail Initial Disclosure Request", "InternalUseOnly", " "),
          custom_field_for("Retail Initial Disclosure Request", "InternalUseOnly", "P"),
        ]
        expect(subject.initial_disclosure_request_completed?).to eq false
      end
    end

    context "wholesale" do
      before do
        subject.channel = Channel.wholesale.identifier
      end

      it "should be completed if any custom field has the right stuff" do
        subject.stub custom_fields: [
          custom_field_for("sdlkfj", "InternalUseOnly", "1/1/1900"),
          custom_field_for("Wholesale Initial Disclosure Request", "sdlfkjdf", "1/1/1900"),
          custom_field_for("Wholesale Initial Disclosure Request", "InternalUseOnly", nil),
          custom_field_for("Retail Initial Disclosure Request", "InternalUseOnly", "1/1/1900"),
          custom_field_for("Wholesale Initial Disclosure Request", "InternalUseOnly", "1/1/1900"),
        ]
        expect(subject.initial_disclosure_request_completed?).to eq true
      end

      it "should not care if there are spaces" do
        subject.stub custom_fields: [
          custom_field_for("Wholesale Initial Disclosure Request", "Internal Use Only", "1/1/1900"),
        ]
        expect(subject.initial_disclosure_request_completed?).to eq true
      end

      it "should not be completed if no custom field has a value for the right field" do
        subject.stub custom_fields: [
          custom_field_for("sdlkfj", "InternalUseOnly", "1/1/1900"),
          custom_field_for("Wholesale Initial Disclosure Request", "sdlfkjdf", "1/1/1900"),
          custom_field_for("Wholesale Initial Disclosure Request", "InternalUseOnly", nil),
          custom_field_for("Wholesale Initial Disclosure Request", "InternalUseOnly", " "),
          custom_field_for("Wholesale Initial Disclosure Request", "InternalUseOnly", "P"),
          custom_field_for("Retail Initial Disclosure Request", "InternalUseOnly", "1/1/1900"),
        ]
        expect(subject.initial_disclosure_request_completed?).to eq false
      end
    end
  end

  describe "docmagic_disclosure_request_created?" do
    it "should be false if there is no event with teh right description" do
      subject.stub loan_events: []
      expect(subject.docmagic_disclosure_request_created?).to eq false
    end

    it "should be true if there is an event with DocMagic Initial Disclosure Request in the description" do
      subject.stub loan_events: [
        LoanEvent.new({event_description: "DocMagic Initial Disclosure Request"}, without_protection: true)
      ]

      expect(subject.docmagic_disclosure_request_created?).to eq true
    end
  end


  describe "initial_disclosure_requested_at" do
    it "should come from the disclosure_request_timestamp table" do
      t = Time.new(2015, 10, 31, 14, 23)
      subject.disclosure_request_timestamp = Master::DisclosureRequestTimestamp.new({disclosure_request_date: t}, without_protection: true)
      expect(subject.initial_disclosure_requested_at).to eq t
    end

    it "should not break on nil" do
      subject.disclosure_request_timestamp = nil
      expect(subject.initial_disclosure_requested_at).to eq nil
    end
  end


  def custom_field_for form, attribute, value
    field = CustomField.new
    field.attribute_unique_name = attribute
    field.form_unique_name = form
    field.attribute_value = value
    field
  end
end
