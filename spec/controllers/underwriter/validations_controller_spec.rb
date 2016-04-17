require "spec_helper"

describe Underwriter::ValidationsController do

  render_views

  let(:instancey) { Loan.first }
  let(:event) { Bpm::StatsRecorder.new.create_new_event(instancey, nil, 'underwriter')}

  before do
    u = fake_rubycas_login
    u.stub(:is_underwriter?) { true }
  end

  describe 'get :search' do
    context "with an id that corresponds to a loan number" do
      before do
        Loan.stub(:find_by_loan_num).with('12345') { instancey }
      end

      describe 'in json format' do
        before do
          get :search, id: '12345', format: :json
        end

        it 'returns a json response' do 
          response.status == 200
        end
      end
    end
  end

  describe 'get :process_validations' do
    context "with an id that corresponds to a loan number" do
      before do
        Loan.stub(:find_by_id).with('12345') { instancey }
        # event = Bpm::StatsRecorder.new.create_new_event()
      end

      describe 'in json format' do
        before do
          Validation::Underwriter.stub do_checks: "stuff"
          Bpm::StatsRecorder.any_instance.stub :record_underwriter_validation_event
        end

        it "should render what comes out of Validation::Underwriter::do_checks" do
          get :process_validations, id: '12345', event_id: event.id, format: :json
          expect(response.status).to eq 200
          expect(response.body).to eq "stuff"
        end

        it "should record stats" do
          expect_any_instance_of(Bpm::StatsRecorder).to receive(:record_underwriter_validation_event).with("stuff", event.id)
          get :process_validations, id: '12345', event_id: event.id, format: :json
        end
      end
    end
  end

end
