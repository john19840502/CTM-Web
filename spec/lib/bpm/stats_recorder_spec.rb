require 'bpm/stats_recorder'
require 'spec_helper'

describe Bpm::StatsRecorder do

  let(:loan) { build_stubbed :loan }
  let(:user) { User.new first_name: 'Greg', last_name: 'Fleming', id: 123, uuid: "f613eaae-fafd-45ab-a84e-62e836311ae6" }
  let(:validation_type) { 'registration' }
  let(:flow) { 'aus' }
  let(:num_rules) { 0 }
  example_decisionator_response =  {:errors=>[], :warnings=>[], :raw_response=>{:flow_name=>"aus", :conclusion=>"Acceptable", :completed=>true, :stop_messages=>[], :warning_messages=>[], :last_decision_view=>"AUSResponseAcceptance", :step_count=>4, :steps_executed_count=>4, 
                    :decision_flow=>[{"Determine AUS Response Acceptance DQ Complete (Base)"=>"Complete"}, {"Determine AUS Response Acceptance DQ Domain Validity (Base)"=>"Valid"}, {"Determine AUS Response Acceptance DQ Value Validity (Base)"=>"Valid"}, {"Determine AUS Response Acceptance (Base)"=>"Acceptable"}], :meta_info=>{"system"=>"CtmdbWeb", "user"=>"UNKONWN", "context"=>"UNKNOWN", "initiation_point"=>"UNKNOWN", "environment"=>"development", 
                      "executed_at"=>"2015-05-15T13:27:33-04:00", "execution_time"=>0.5311522483825684}, :instance_fact_types=>{}, :uuid=>"988de380-dd55-0132-af23-005056b81fc0"}, :conclusion=>"Acceptable"}
  ex_fact_types = {"UnderwritingStatus"=>"Final Approval/Ready For Docs", "AUSRecommendation"=>"NA Accept Accept", "LoanProductName"=>"FHA15FXD", "AUSRiskAssessment"=>"LP", "OccupancyType"=>"Primary", "RiskAssessment"=>"AUS"}

  let(:result) {example_decisionator_response}
  def a_message
    {rule_id: 123, text: 'foo', history: [] }
  end

  describe "record_validation_event" do
    let(:fact_types) {ex_fact_types}
    let(:event) {Bpm::LoanValidationEvent.new}
    it "should create validation event for the executed validations" do
      event.id = 123
      allow(Bpm::LoanValidationEvent).to receive('find').with(123) {event}
      subject.record_validation_event(flow,123,result, fact_types)
      expect(Bpm::LoanValidationEvent.last.loan_validation_flows.count).to eq(1)
      expect(Bpm::LoanValidationEvent.last.loan_validation_flows.first.name).to eq('aus')
      expect(Bpm::LoanValidationEvent.last.loan_validation_flows.first.conclusion).to eq('Acceptable')
    end
  end

  describe "#create_new_event" do
    let(:event) { subject.create_new_event loan, user, validation_type }
    context "when user is missing" do
      let(:user) { nil }
      it { event.validated_by_id.should == nil }
      it { event.validated_by.should == nil }
    end

    context "when user is present" do
      it { expect(event.validated_by_id).to eq("f613eaae-fafd-45ab-a84e-62e836311ae6")}
      it { event.validated_by.should == 'Greg Fleming' }
    end

    context "when there are no underwriters" do
      before { loan.loan_general.stub loan_assignees: [] }

      it { event.underwriter.should == 'n/a' }
    end

    context "when there are underwriters" do
      before do
        loan.loan_general.stub loan_assignees: [
          LoanAssignee.new({first_name: 'Alice', last_name: 'Apple', role: 'Underwriter'}, without_protection: true),
          LoanAssignee.new({first_name: 'Bob', last_name: 'Buzzkill', role: 'sofmdsf'}, without_protection: true),
          LoanAssignee.new({first_name: 'Charlie', last_name: 'Chaplin', role: 'Underwriter'}, without_protection: true),
        ]
      end

      it { event.underwriter.should == "Alice Apple, Charlie Chaplin" }
    end

    it "should store the loan's loan_num" do
      loan.stub loan_num: '1234567'
      event.loan_num.should == '1234567'
    end

    it "should store the loan's product code" do
      loan.stub product_code: 'ABCDE'
      event.product_code.should == 'ABCDE'
    end

    it "should store the loan's channel" do
      loan.stub channel: 'A0 Whatever'
      event.channel.should == 'A0 Whatever'
    end

    it "should store the loan's state" do
      loan.loan_general.stub property_state: 'MI'
      event.property_state.should == 'MI'
    end

    it "should sotre the loan's status" do
      loan.stub loan_status: 'Purchased'
      event.loan_status.should == 'Purchased'
    end

    it "should record the loan's pipeline status" do 
      loan.loan_general.stub additional_loan_datum: AdditionalLoanDatum.new({pipeline_lock_status_description: 'Lock Expired'}, without_protection: true)
      event.pipeline_lock_status.should == 'Lock Expired'
    end

    it "should handle missing pipeline status" do
      loan.loan_general.stub additional_loan_datum: nil
      event.pipeline_lock_status.should == nil
    end

    it "should store error messages as errors" do
      result[:errors] << a_message.merge(text: 'yatta')
      subject.record_validation_event flow, event.id, result, ex_fact_types
      event.loan_validation_flows[0].loan_validation_event_messages[0].loan_validation_message_type.message_type == 'error'
      event.loan_validation_flows[0].loan_validation_event_messages.map{|m| m.loan_validation_message_type.name}.compact.uniq.should == [ 'yatta' ]
    end

    it "should store warning messages as warnings" do
      result[:warnings] << a_message.merge(text: 'yatta')
      result[:warnings] << a_message.merge(text: 'nonsense')
      subject.record_validation_event flow, event.id, result, ex_fact_types
      event.loan_validation_flows[0].loan_validation_event_messages[0].loan_validation_message_type.message_type == 'warning'
      event.loan_validation_flows[0].loan_validation_event_messages.map{|m| m.loan_validation_message_type.name}.compact.uniq.should == [ 'yatta', 'nonsense' ]
    end

    ['a', 'b'].each do |vt|
      context "when validation type is #{vt}" do
        let(:validation_type) { vt }
        it { event.validation_type.should == vt}
      end
    end

  end


  describe "for underwriter validations" do
    let(:event) { Bpm::LoanValidationEvent.create! }
    let(:results) do 
      { errors: [], warnings: [] }
    end

    describe "status" do
      context "no errors or warnings" do
        it "should use whatever the previous status was" do
          event.validation_status = 'foo'
          event.save!
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "foo"
        end
      end

      context "when there are errors" do
        let(:error) { results[:errors].first }
        before do
          results[:errors] << a_message
        end

        it "should mark the event as failed" do
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "FAIL"
        end

        it "should not mark failed when the error is cleared" do
          error[:history] = [ { action: 'Cleared' }]
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "PASS"
        end

        it "should fail if any error is uncleared" do
          error[:history] = [ { action: 'Cleared' }]
          results[:errors] << a_message
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "FAIL"
        end

        it "should fail if the error was reinstated after being cleared" do
          error[:history] = [ { action: 'Reinstated' }, { action: 'Cleared' }]
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "FAIL"
        end
      end

      context "when there are warnings" do
        let(:warning) { results[:warnings].first }
        before do
          results[:warnings] << a_message
        end

        it "hsould mark the event as review" do
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "REVIEW"
        end

        it "should still fail if there are also errors" do
          results[:errors] << a_message
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "FAIL"
        end

        it "should not mark review if the warnings are all cleared" do
          warning[:history] = [ { action: 'Cleared' }]
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "PASS"
        end

        it "should mark review if some of the warnings are uncleared" do
          warning[:history] = [ { action: 'Cleared' }]
          results[:warnings] << a_message
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "REVIEW"
        end

        it "should review if the warning was reinstated after being cleared" do
          warning[:history] = [ { action: 'Reinstated' }, { action: 'Cleared' }]
          subject.record_underwriter_validation_event results, event.id
          event.reload
          expect(event.validation_status).to eq "REVIEW"
        end
      end
    end

    describe "flow" do
      let(:reloaded_event) do
        subject.record_underwriter_validation_event results, event.id
        event.reload
        event
      end

      let(:flow) { reloaded_event.loan_validation_flows.first }

      it "should record a fake flow for this validation" do
        expect(reloaded_event.loan_validation_flows.size).to eq 1
        expect(flow.name).to eq "uw validation"
      end

      describe "conclusion" do
        it "should be Not Acceptable when there are errors" do
          results[:errors] << a_message
          expect(flow.conclusion).to eq "Not Acceptable"
        end

        it "should be Acceptable with no errors" do
          expect(flow.conclusion).to eq "Acceptable"
        end
      end

      describe "messages" do

        it "should have messages for each error" do
          results[:errors] << a_message.merge(text: 'blah')
          results[:errors] << a_message.merge(text: 'ugh')

          a = flow.loan_validation_event_messages.first
          expect(a.loan_validation_message_type.message_type).to eq 'error'
          expect(a.loan_validation_message_type.name).to eq 'blah'

          b = flow.loan_validation_event_messages.drop(1).first
          expect(b.loan_validation_message_type.message_type).to eq 'error'
          expect(b.loan_validation_message_type.name).to eq 'ugh'
        end

        it "should have messages for each warning" do
          results[:warnings] << a_message.merge(text: 'blah')
          results[:warnings] << a_message.merge(text: 'ugh')

          a = flow.loan_validation_event_messages.first
          expect(a.loan_validation_message_type.message_type).to eq 'warning'
          expect(a.loan_validation_message_type.name).to eq 'blah'

          b = flow.loan_validation_event_messages.drop(1).first
          expect(b.loan_validation_message_type.message_type).to eq 'warning'
          expect(b.loan_validation_message_type.name).to eq 'ugh'
        end
      end
    end

  end
end
