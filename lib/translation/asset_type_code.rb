module Translation
  class AssetTypeCode
    attr_accessor :asset_type
    def initialize(asset_type)
      @asset_type = asset_type
    end

    TRANSLATION =
        {
            'Automobile'                                 => 4,
            'Bond'                                       => 4,
            'BridgeLoanNotDeposited'                     => 5,
            'EarnestMoneyCashDepositTowardPurchase'      => 1,
            'CashOnHand'                                 => 2,
            'CertificateOfDepositTimeDeposit'            => 4,
            'CheckingAccount'                            => 1,
            'GiftsTotal'                                 => 3,
            'GiftsNotDeposited'                          => 3,
            'LifeInsurance'                              => 3,
            'MoneyMarketFund'                            => 4,
            'MutualFund'                                 => 4,
            'PendingNetSaleProceedsFromRealEstateAssets' => 3,
            'NetWorthOfBusinessOwned'                    => 3,
            'OtherNonLiquidAssets'                       => 3,
            'OtherLiquidAssets'                          => 4,
            'RetirementFund'                             => 4,
            'SavingsAccount'                             => 1,
            'SecuredBorrowedFundsNotDeposited'           => 3,
            'Stock'                                      => 4,
            'TrustAccount'                               => 3
        }

    def translate
      TRANSLATION[asset_type]
    end
  end
end