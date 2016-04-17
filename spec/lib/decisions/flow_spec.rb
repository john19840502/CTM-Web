require 'spec_helper'

describe Decisions::Flow do

  example_decisionator_response = {conclusion: 'Fail',
                                   stop_messages: ['Invalid Product'],
                                   warning_messages: ["Warning Message!"],
                                   raw_response: {a: 1, b: 2, c: 3} }

  let(:flow) { Decisions::Flow.new("product_eligibility", fact_types) }
  let(:fact_types) { {'PropertyState' => 'Michigan'} }
  let(:decisionator_response) { example_decisionator_response }

  before do
    Ctmdecisionator::Flow.stub("execute").and_return(decisionator_response)
    flow.call_decisionator
  end

  it 'extracts the raw decisionator response' do
    flow.extract_raw_response

    flow.result[:raw_response].should eq(example_decisionator_response)
  end

  it 'extracts the conclusion from the decisionator response' do
    flow.extract_conclusion

    flow.result[:conclusion].should eq('Fail')
  end

  it 'extracts the errors from the decisionator response' do
    flow.extract_error_messages

    flow.result[:errors].should eq([{ rule_id: 1025, text: 'Invalid Product'}])
  end

  it 'extracts the warning messages with a warning identifier' do
    flow.extract_warning_messages

    flow.result[:warnings].should eq([{ rule_id: 1025, text: 'Warning Message!'}])
  end

  it 'does not extract a warning message if there is no rule id associated with the flow' do
    flow.stub('flow_rule_id') {}
    flow.extract_warning_messages

    flow.result[:warnings].should eq([])
  end
end
