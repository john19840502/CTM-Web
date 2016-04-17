require 'spec_helper'

module InitialDisclosure

  describe WorkQueueHelper do

    describe ".age_from_date" do 

      context "when starting on a business day" do
        let(:from_date) { DateTime.new(2015, 9, 28, 10, 0, 0) }

        it "should count same day as 0" do
          expect(helper.age_from_date(from_date, Date.new(2015, 9, 28))).to eq 0
        end

        it "should count next day as 1" do
          expect(helper.age_from_date(from_date, Date.new(2015, 9, 29))).to eq 1
        end

        it "should not count weekend days" do
          expect(helper.age_from_date(from_date, Date.new(2015, 10, 2))).to eq 4 # Friday
          expect(helper.age_from_date(from_date, Date.new(2015, 10, 5))).to eq 5 # Monday
        end

        it "should not count holidays" do
          expect(helper.age_from_date(Date.new(2015,9,4), Date.new(2015, 9, 8))).to eq 1 # Day after Labor Day
        end

      end

      context "when starting on a non-business day" do

        it "should count Monday as 0 when starting on a Saturday" do
          expect(helper.age_from_date(Date.new(2015, 10, 3), Date.new(2015, 10, 5))).to eq 0 # Monday
        end

        it "should count the next day as zero when starting on a holiday" do
          expect(helper.age_from_date(Date.new(2015,9,7), Date.new(2015, 9, 8))).to eq 0 # Day after Labor Day
        end

      end

      context "when given bad data" do

        it "should not attempt to process nil date" do
          expect(helper.age_from_date nil).to be_nil
        end

        it "should not blow up if dates are in wrong order" do
          expect(helper.age_from_date(Date.new(2015, 10, 2), Date.new(2015, 10, 1))).to eq 0
        end

        it "should use today if nil is passed in as end date" do
          val_with_today = helper.age_from_date(Date.yesterday, Date.today)
          val_with_nil = helper.age_from_date(Date.yesterday, nil)

          expect(val_with_nil).to eq val_with_today
        end

        it "should use today if end date is not passed in" do
          val_with_today = helper.age_from_date(Date.yesterday, Date.today)
          val_with_no_end = helper.age_from_date(Date.yesterday)

          expect(val_with_no_end).to eq val_with_today
        end

      end

    end

    describe ".title_vendor_for" do

      it "should return the vendor for the state when loan is retail" do
        loan = double
        title_vendor = state_title_vendor("FB", 1, 2)
        allow(loan).to receive(:property_state_translated).and_return "FB"
        allow(loan).to receive(:channel).and_return Channel.retail.identifier
        StateTitleVendor.stub(:find_by_state).with("FB").and_return title_vendor

        expect(helper.title_vendor_for(loan)).to eq Vendor.find(1).name
      end

      it "should return the vendor for the state when loan is wholesale" do
        loan = double
        title_vendor = state_title_vendor("FB", 2, 3)
        allow(loan).to receive(:property_state_translated).and_return "FB"
        allow(loan).to receive(:channel).and_return Channel.wholesale.identifier
        StateTitleVendor.stub(:find_by_state).with("FB").and_return title_vendor

        expect(helper.title_vendor_for(loan)).to eq Vendor.find(3).name
      end

      it "should handle case for unmapped state" do
        loan = double
        title_vendor = state_title_vendor("FB", 2, 3)
        allow(loan).to receive(:property_state_translated).and_return "FB"
        allow(loan).to receive(:channel).and_return Channel.wholesale.identifier
        StateTitleVendor.stub(:find_by_state).with("FB").and_return nil

        expect(helper.title_vendor_for(loan)).to eq nil
      end

      def state_title_vendor code, retail_id, wholesale_id
        StateTitleVendor.new(:state => code, :retail_vendor_id => retail_id, :wholesale_vendor_id => wholesale_id)
      end

    end

  end
end