require 'spec_helper'

describe FundingModeler do
  describe ".update_from_params" do
    context 'ny mtg tax is 14' do
      before { subject.ny_mtg_tax = 14 }

      context "if not locked and ny_mtg_tax is 14" do
        before do
          subject.fund_lock = false
        end

        context "with ny_mtg_tax in parameters" do
          let(:params) { {ny_mtg_tax: 21}}

          it "should change ny_mtg_tax" do
            subject.stub(:save) { true }
            subject.update_from_params(params)
            subject.ny_mtg_tax.should == 21
          end
        end
      end

      context "if locked" do
        before do
          subject.fund_lock = true
        end

        context "with ny_mtg_tax in parameters" do
          let(:params) { {ny_mtg_tax: 21}}

          it "should not change ny_mtg_tax" do
            subject.stub(:save) { true }
            subject.update_from_params(params)
            subject.ny_mtg_tax.should == 14
          end
        end
      end

      context 'fund toggle lock in params is blank' do
        let(:params) { {f_toggle_lock: ''} }

        it 'should not toggle fund_lock' do
          subject.should_not_receive(:toggle_lock)
          subject.update_from_params(params)
        end
      end

      context 'fund toggle lock in params is present' do
        let(:params) { {f_toggle_lock: 'true'} }

        it 'should toggle fund_lock' do
          subject.should_receive(:toggle_lock)
          subject.update_from_params(params)
        end
      end

      context 'toggle lock when fund lock is true' do
        before do
          subject.fund_lock = true
          subject.toggle_lock
        end
        it 'should set fund lock to false' do
          subject.fund_lock.should == false
        end
      end
    end
  end
end
