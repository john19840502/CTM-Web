require 'spec_helper'

describe ProductGuideline do 

	ProductGuideline.delete_all
	subject { ProductGuideline.create!(product_code: "FOOBAR")}

	before do
		create_new_doc(subject.id)
	end
	
	describe "#to_label" do
		it "should create new ProductGuideline with correct label" do
			subject.to_label.should match("Product Code: FOOBAR")
		end
	end

	describe "#current_guideline" do
		it "should return ProductGuidelineDoc " do 
			channel = "Wholesale"
			subject.current_guideline(channel).channel.should match("Wholesale")
			subject.current_guideline(channel).effective_date.should < Date.tomorrow
		end

		it "should not return ProductGuidelineDoc" do 
			channel = "foo_bar"
			subject.current_guideline(channel).should be_nil
		end
	end

	def create_new_doc(prod_guide_id)
		new_doc = ProductGuidelineDoc.new
		new_doc.product_guideline_id = prod_guide_id
		new_doc.effective_date = Date.today
		new_doc.channel = 'Wholesale'
		new_doc.document = File.open(Rails.root.join('./spec/data/rails.pdf'))
		new_doc.save
	end

end