require 'spec_helper'

describe "delivery/_related_loan.xml.builder" do
  it 'should be ok with a liability as the related loan' do
    render partial: 'delivery/delivery/related_loan', locals: { builder: Builder::XmlMarkup.new, loan: Master::Liability.new }, format: :xml
  end

  it 'should be ok with a new transaction detail as the related loan' do
    render partial: 'delivery/delivery/related_loan', locals: { builder: Builder::XmlMarkup.new, loan: TransactionDetail.new }, format: :xml
  end

  it 'should be ok with a heloc transaction detail as the related loan' do
    loan = TransactionDetail.new(undrawn_heloc_amount: 10000)
    render partial: 'delivery/delivery/related_loan', locals: { builder: Builder::XmlMarkup.new, loan: loan }, format: :xml
  end
end
