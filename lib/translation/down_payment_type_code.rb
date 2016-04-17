module Translation
  class DownPaymentTypeCode
    attr_accessor :down_payment_type
    def initialize(down_payment_type)
      @down_payment_type = down_payment_type
    end

    TRANSLATION =
        {
            'CheckingSavings'                                          => 'H',
            'DepositOnSalesContract'                                   => '',
            'EquityOnSoldProperty'                                     => '',
            'EquityFromPendingSale'                                    => '',
            'EquityOnSubjectProperty'                                  => '',
            'GiftFunds'                                                => 'G',
            'StocksAndBonds'                                           => '',
            'LotEquity'                                                => '',
            'BridgeLoan'                                               => 'S',
            'UnsecuredBorrowerFunds'                                   => 'D',
            'TrustFunds'                                               => '',
            'RetirementFunds'                                          => '',
            'RentWithOptionToPurchase'                                 => '',
            'LifeInsuranceCashValue'                                   => '',
            'SaleOfChattel'                                            => '',
            'TradeEquity'                                              => '',
            'SweatEquity'                                              => 'W',
            'OtherTypeOfDownPayment'                                   => '',
            'SecuredBorrowedFunds'                                     => '',
            'CashOnHand'                                               => 'C',
            'FHAGiftSourceNA'                                          => '',
            'FHAGiftSourceRelative'                                    => '',
            'FHAGiftSourceGovernmentAssistance'                        => '',
            'FHAGiftSourceEmployer'                                    => '',
            'FHAGiftSourceNonprofitReligiousCommunitySellerFunded'     => '',
            'FHAGiftSourceNonprofitReligiousCommunityNon-SellerFunded' => ''
        }

    def translate
      TRANSLATION[down_payment_type]
    end
  end
end