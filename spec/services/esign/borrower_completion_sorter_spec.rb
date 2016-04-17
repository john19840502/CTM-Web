require 'spec_helper'

describe Esign::BorrowerCompletionSorter do

  describe ".default_sort" do

    it "should order by date and group by loan number" do
      records = [ OpenStruct.new(loan_number: "6000001", esign_signer: signer(1, 1.hours.ago)),
                  OpenStruct.new(loan_number: "6000002", esign_signer: signer(2, 2.hours.ago)),
                  OpenStruct.new(loan_number: "6000001", esign_signer: signer(3, 3.hours.ago)),
                  OpenStruct.new(loan_number: "6000003", esign_signer: signer(4, 4.hours.ago)),
                  OpenStruct.new(loan_number: "6000003", esign_signer: signer(5, 3.hours.ago)),
                  OpenStruct.new(loan_number: "6000002", esign_signer: signer(6, 1.hours.ago)) ]

      sorted_records = Esign::BorrowerCompletionSorter.call records

      expect(sorted_records.size).to eq 6
      expect(sorted_records[0].esign_signer.id).to eq 4
      expect(sorted_records[1].esign_signer.id).to eq 5
      expect(sorted_records[2].esign_signer.id).to eq 3
      expect(sorted_records[3].esign_signer.id).to eq 1
      expect(sorted_records[4].esign_signer.id).to eq 2
      expect(sorted_records[5].esign_signer.id).to eq 6
    end

  end

  def signer id, ts
    s = OpenStruct.new
    s.id = id
    s.completed_date = ts
    allow(s).to receive(:esign_completed_date).and_return ts
    s
  end

end