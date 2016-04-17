class CompTier < DatabaseDatamartReadonly
  belongs_to :institution, foreign_key: :institution_number, primary_key: :institution_number

  def self.sqlserver_create_view
    <<-eos
      SELECT     ID AS id,
                 Institution_Number as institution_number,
                 Channel_Mortgage_Type as channel_mortgage_type,
                 Comp_Tier as comp_tier,
                 SMDS_Product_ID as product_id,
                 State_ID as state,
                 Effective_In_Date as effective_at,
                 Effective_Out_Date as effective_until,
                 Maximum_Compensation as maximum_compensation,
                 Minimum_Compensation as minimum_compensation,
                 Create_Date as created_at,
                 Update_Date as updated_at
      FROM       CTM.ctm.[Comp_Tier]
    eos
  end

end
