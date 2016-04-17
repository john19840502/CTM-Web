require 'spec_helper'

describe Institution do
  describe 'instance methods' do
    it { should be_valid }
  end

  describe "active_at" do
    let(:the_date) {Date.new(2012, 1, 1)}

    it "should not include institutions whose activated date is after the parameter" do
      id = Institution.where{activated_date > my{the_date} }.order(:activated_date).pluck(:id).first
      Institution.active_at(the_date).pluck(:id).should_not include(id)
    end

    it "should include institutions active before the date but not terminated" do
      id = Institution.where{(activated_date <= my{the_date}) & (terminated_date == nil) } \
                      .order("activated_date desc").pluck(:id).first
      Institution.active_at(the_date).pluck(:id).should include(id)
    end

    it "should not include institutions terminated before the date" do
      id = Institution.where{terminated_date <= my{the_date} } \
                      .order("terminated_date desc").pluck(:id).first
      Institution.active_at(the_date).pluck(:id).should_not include(id)
    end

    it "should include institutions active before and terminated after the date" do
      id = Institution.where{(activated_date <= my{the_date}) & (terminated_date > my{the_date}) } \
                      .order("activated_date desc").pluck(:id).first
      Institution.active_at(the_date).pluck(:id).should include(id)
    end
  end

  describe "Consumer Direct branch name should include CD at its end" do
    it "name should not include CD at its end when channel is not Consumer Direct" do
      subject = build_stubbed(:institution, name: 'MB Financial Bank, N.A.', channel: Channel.retail.identifier, city: 'Milford')
      subject.branch_name.should eq('MB Milford')
    end

    it "name should include CD at its end when channel is Consumer Direct" do
      subject = build_stubbed(:institution, name: 'MB Financial Bank, N.A.', channel: Channel.consumer_direct.identifier, city: 'Milford')
      subject.branch_name.should eq('MB Milford CD')
    end

    it "name should include CD at its end when channel is Consumer Direct" do
      subject = build_stubbed(:institution, name: 'Cole Taylor Bank', channel: Channel.consumer_direct.identifier, city: 'Milford')
      subject.branch_name.should eq('MB Milford CD')
    end
  end

end
