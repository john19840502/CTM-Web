module Translation
  class DownPaymentSource
    attr_accessor :down_payment_type
    def initialize(down_payment_type)
      @down_payment_type = down_payment_type
    end

    TRANSLATION =
        {
            'CheckingSavings'                                          => '07',
            'DepositOnSalesContract'                                   => '07',
            'EquityOnSoldProperty'                                     => '10',
            'EquityFromPendingSale'                                    => '10',
            'EquityOnSubjectProperty'                                  => '10',
            'GiftFunds'                                                => '01',
            'StocksAndBonds'                                           => '08',
            'LotEquity'                                                => '10',
            'BridgeLoan'                                               => '10',
            'UnsecuredBorrowerFunds'                                   => '10',
            'TrustFunds'                                               => '07',
            'RetirementFunds'                                          => '07',
            'RentWithOptionToPurchase'                                 => '10',
            'LifeInsuranceCashValue'                                   => '07',
            'SaleOfChattel'                                            => '10',
            'TradeEquity'                                              => '10',
            'SweatEquity'                                              => '10',
            'OtherTypeOfDownPayment'                                   => '10',
            'SecuredBorrowedFunds'                                     => '07',
            'CashOnHand'                                               => '07',
            'FHAGiftSourceNA'                                          => '10',
            'FHAGiftSourceRelative'                                    => '01',
            'FHAGiftSourceGovernmentAssistance'                        => '03',
            'FHAGiftSourceEmployer'                                    => '06',
            'FHAGiftSourceNonprofitReligiousCommunitySellerFunded'     => '02',
            'FHAGiftSourceNonprofitReligiousCommunityNon-SellerFunded' => '02'
        }

    def translate
      TRANSLATION[down_payment_type]
    end
  end
end