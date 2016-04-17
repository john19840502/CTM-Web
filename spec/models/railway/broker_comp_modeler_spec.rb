require 'spec_helper'

describe BrokerCompModeler do

	BrokerCompModeler.delete_all
	subject { BrokerCompModeler.create!({ user_comments: "original comments", total_broker_comp_gfe: 1000, modeler_date_time: 'original time', modeler_user: "original user" }, without_protection: true) }
	let(:user) { build_stubbed_user }
	before do 
  	subject.stub current_user:  user
	end

	it "should save the broker comp" do
  	subject.update_from_params total_gfe_broker_comp: 2000	
  	subject.reload.total_broker_comp_gfe.should  eq("2000")
	end

	it "should save the comments" do
  	subject.update_from_params user_comments: "new comments"
  	subject.reload.user_comments.should eq("new comments")
	end

	context "when the comments are different" do

  	let(:params) { {user_comments: 'new comments' } }

  	it "should save the current time" do
    	Time.stub now: Time.new(2000, 11, 22, 13, 45, 56)
    	subject.update_from_params params
    	subject.reload.modeler_date_time.to_date.should == Time.now.to_date 
  	end
  	it "should save the current user name" do
	    user.stub display_name: "Bob Smith"
	    subject.update_from_params params
	    subject.reload.modeler_user.should  eq("Bob Smith")
	  end
  end

  context "when the comments are not different" do

	  let(:params) { {user_comments: 'original comments' } }

	  it "should not save the current time" do
	    subject.update_from_params params
	    subject.reload.modeler_date_time.should  eq("original time")
	  end

	  it "should save the current user name" do
	    subject.update_from_params params
	    subject.reload.modeler_user.should  eq("original user")
	  end
	end
end
