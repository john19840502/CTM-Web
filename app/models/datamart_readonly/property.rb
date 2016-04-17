class Property < DatabaseDatamartReadonly

  belongs_to :loan_general
  # belongs_to :loan, through: :loan_general


  def self.sqlserver_create_view
    # <<-eos
    #   SELECT     vl.LoanNum AS id,
    #              vl.LoanNum AS loan_id,
    #              lf.GSEPropertyType AS property_type,
    #              p._City AS city,
    #              p._County AS county,
    #              p._CountyCode AS county_code,
    #              p._FinancedNumberOfUnits as num_of_units,
    #              p._PostalCode AS zip,
    #              p._State AS state,
    #              p._StreetAddress AS address,
    #              p._StreetAddressName AS street_name,
    #              p._StreetAddressNumber AS street_number,
    #              p._StreetAddressUnit AS street_unit,
    #              p.loanGeneral_Id AS loan_general_id,
    #              p.PlannedUnitDevelopmentIndicator AS planned_unit_development_indicator
    #              tx.PropertyAppraisedValueAmount AS appraised_value,
    #   FROM         LENDER_LOAN_SERVICE.dbo.vwLoan AS vl INNER JOIN
    #                         LENDER_LOAN_SERVICE.dbo.PROPERTY AS p ON vl.loanGeneral_Id = p.loanGeneral_Id INNER JOIN
    #                         LENDER_LOAN_SERVICE.dbo.LOAN_FEATURES AS lf ON vl.loanGeneral_Id = lf.loanGeneral_Id INNER JOIN
    #                         LENDER_LOAN_SERVICE.dbo.TRANSMITTAL_DATA AS tx ON vl.loanGeneral_Id = tx.loanGeneral_Id
    # eos

    <<-eos
      SELECT  PROPERTY_id  AS id,
                loanGeneral_Id                    AS loan_general_id,
                _City                             AS city,
                _County                           AS county,
                _CountyCode                       AS county_code,
                _FinancedNumberOfUnits            AS num_of_units,
                _PostalCode                       AS zip,
                _State                            AS state,
                _StreetAddress                    AS address,
                _StreetAddressName                AS street_name,
                _StreetAddressNumber              AS street_number,
                _StreetAddressUnit                AS street_unit,
                _StructureBuiltYear               AS structure_built_year,
                PlannedUnitDevelopmentIndicator   AS planned_unit_development_indicator
      FROM    LENDER_LOAN_SERVICE.dbo.[PROPERTY]
    eos
  end

  def city_state_zip
    "#{city}, #{state} #{zip}"
  end

  def city_state
    "#{city} #{state}"
  end

  def county_fips
    "%03d" % county_code rescue '000'
  end

  def property_type
    self.loan_general.loan.gse_property_type
  end
end

# [_StructureBuiltYear] [int] NULL,
# [AssessorsParcelIdentifier] [varchar](50) NULL,
# [BuildingStatusType] [varchar](80) NULL,
# [ManufactureredHomeMake] [varchar](75) NULL,
# [ManufactureredHomeYear] [varchar](20) NULL,
