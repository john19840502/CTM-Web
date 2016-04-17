require 'spec_helper'

describe HpmlResult do
  subject { HpmlResult }

  it 'should be able to get the result when it is true' do
    loan = Master::Loan.new
    loan.compliance_alerts = [Master::ComplianceAlert.new({hpml_alert_test: 'Fail'}, without_protection: true)]
    subject.for(loan).should == true
  end

  it 'should be able to get the result when it is false' do
    loan = Master::Loan.new
    loan.compliance_alerts = [Master::ComplianceAlert.new({hpml_alert_test: 'Pass'}, without_protection: true)]
    subject.for(loan).should == false
  end
end
