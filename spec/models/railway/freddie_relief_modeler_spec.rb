require 'spec_helper'

describe FreddieReliefModeler do
  describe ".update_from_params" do
    context 'upb is 14' do
      before { subject.upb = 14 }

      context "if not locked and upb is 14" do
        before do
          subject.fredd_lock = false
        end

        context "with upb in parameters" do
          let(:params) { {upb: 21}}

          it "should change upb" do
            subject.stub(:save) { true }
            subject.update_from_params(params)
            subject.upb.should == 21
          end
        end
      end

      context "if locked" do
        before do
          subject.fredd_lock = true
        end

        context "with upb in parameters" do
          let(:params) { {upb: 21}}

          it "should not change upb" do
            subject.stub(:save) { true }
            subject.update_from_params(params)
            subject.upb.should == 14
          end
        end
      end

      context 'fredd toggle lock in params is blank' do
        let(:params) { {fredd_toggle_lock: ''} }

        it 'should not toggle fredd_lock' do
          subject.should_not_receive(:toggle_lock)
          subject.update_from_params(params)
        end
      end

      context 'fredd toggle lock in params is present' do
        let(:params) { {fredd_toggle_lock: 'true'} }

        it 'should toggle fredd_lock' do
          subject.should_receive(:toggle_lock)
          subject.update_from_params(params)
        end
      end

      context 'toggle lock when fund lock is true' do
        before do
          subject.fredd_lock = true
          subject.toggle_lock
        end
        it 'should set fredd lock to false' do
          subject.fredd_lock.should == false
        end
      end
    end
  end
end
