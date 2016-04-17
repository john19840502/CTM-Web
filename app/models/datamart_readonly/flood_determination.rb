class FloodDetermination < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT 
        FLOOD_DETERMINATION_id                AS id,
        loanGeneral_Id                        AS loan_general_id,
        SpecialFloodHazardAreaIndicator       AS special_flood_hazard_area_indicator,
        NFIPFloodZoneIdentifier               AS nfip_flood_zone_identifier
      FROM LENDER_LOAN_SERVICE.dbo.[FLOOD_DETERMINATION]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
