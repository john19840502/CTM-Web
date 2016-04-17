require 'servicing/boarding_file_builder'
require 'servicing/card_deck_builder'

describe Servicing::BoardingFileBuilder do

  subject { Servicing::BoardingFileBuilder.new }
  let(:builder) { subject }
  let(:loan) { Master::Loan.new }
  let(:primary_borrower) { build_fake_borrower borrower_id: 'BRW1' }
  let(:secondary_borrower) { build_fake_borrower borrower_id: 'BRW2' }
  let(:translator) { builder.translator(loan) }
  let(:deck) { builder.card_deck(loan) }

  describe "header" do
    it "should put a bunch of stuff in" do
      DateTime.stub now: DateTime.new(2012, 6, 29, 13, 54, 23)
      subject.header.should == "  112062913:54:2302" + " " * 61
    end
  end

  it "should make a deck for each loan and concat them" do
    loan_a = Master::Loan.new
    loan_b = Master::Loan.new
    a = builder.translator_factory.build_translator_for loan_a
    b = builder.translator_factory.build_translator_for loan_b
    builder.translator_factory.stub(:build_translator_for).with(loan_a).and_return(a)
    builder.translator_factory.stub(:build_translator_for).with(loan_b).and_return(b)
    boarding_file = BoardingFile.new
    boarding_file.stub loans: [loan_a,loan_b]

    builder_a = Servicing::CardDeckBuilder.new a
    builder_b = Servicing::CardDeckBuilder.new b
    Servicing::CardDeckBuilder.stub(:new).with(a).and_return(builder_a)
    Servicing::CardDeckBuilder.stub(:new).with(b).and_return(builder_b)
    builder_a.stub card_deck: 'foo'
    builder_b.stub card_deck: 'bar'

    builder.build(boarding_file).should end_with("foo\r\nbar")
  end


end
