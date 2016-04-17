require 'spec_helper'

describe DoddFrankModeler do
  describe ".update_from_params" do
    context 'hoi premium is 14' do
      before { subject.hoi_premium = 14 }

      context "if not locked and hoi_premium is 14" do
        before do
          subject.fd_lock = false
        end

        context "with hoi_premium in parameters" do
          let(:params) { {hoi_premium: 21}}

          it "should change hoi_premium" do
            subject.stub(:save) { true }
            subject.update_from_params(params)
            subject.hoi_premium.should == 21
          end
        end
      end

      context "if locked" do
        before do
          subject.fd_lock = true
        end

        context "with hoi_premium in parameters" do
          let(:params) { {hoi_premium: 21}}

          it "should not change hoi_premium" do
            subject.stub(:save) { true }
            subject.update_from_params(params)
            subject.hoi_premium.should == 14
          end
        end
      end

      context 'toggle lock in params is blank' do
        let(:params) { {toggle_lock: ''} }

        it 'should not toggle fd_lock' do
          subject.should_not_receive(:toggle_lock)
          subject.update_from_params(params)
        end
      end

      context 'toggle lock in params is present' do
        let(:params) { {toggle_lock: 'true'} }

        it 'should toggle fd_lock' do
          subject.should_receive(:toggle_lock)
          subject.update_from_params(params)
        end
      end

      context 'toggle lock when fd lock is true' do
        before do
          subject.fd_lock = true
          subject.toggle_lock
        end
        it 'should set fd lock to false' do
          subject.fd_lock.should == false
        end
      end
    end
  end
end
