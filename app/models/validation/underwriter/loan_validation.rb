module Validation
  module Underwriter

    class LoanValidation
      include Validation::Underwriter::FactTypes

      attr_reader :errors, :warnings, :loan

      def initialize(loan)
        @loan = loan
        @errors = []
        @warnings = []
      end

      # ATLAS-26
      def govt_monitoring_app_taken_by_required
        if @loan.interviewer and @loan.interviewer.application_taken_method_type.blank? #and loan is government monitored
          errors << '1003 - government monitoring - application taken by must be completed.'
        end
      end

      # ATLAS-27
      def govt_monitoring_app_taken_by_f2f_ethnicity_gender_race_are_required
        if @loan.interviewer and @loan.interviewer.application_taken_method_type.eql?("FaceToFace")
          borrowers = @loan.loan_general.borrowers.map(&:borrower_id)
          borrowers.each do |borrower|
            if (%w(Male Female).includes_none?(@loan.loan_general.government_monitorings.select{|gm| gm.borrower_id == borrower}.map(&:gender_type)) or
             %w(HispanicOrLatino NotHispanicOrLatino).includes_none?(@loan.loan_general.government_monitorings.select{|gm| gm.borrower_id == borrower}.map(&:hmda_ethnicity_type)) or
             @loan.loan_general.hmda_races.select{|hm| hm.borrower_id == borrower}.count.eql?(0))
              errors << 'Application was taken face to face, government monitoring information must be completed and cannot be "Information not Provided"'
            end
          end
        end
      end

      # ATLAS-28
      def govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required
        if (@loan.interviewer.nil? or !@loan.interviewer.application_taken_method_type.eql?("FaceToFace"))
          borrowers = @loan.loan_general.borrowers.map(&:borrower_id)
          borrowers.each do |borrower|
            if (%w(Male Female InformationNotProvidedUnknown NotApplicable).includes_none?(@loan.loan_general.government_monitorings.select{|gm| gm.borrower_id == borrower}.map(&:gender_type)) or
               %w(InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication HispanicOrLatino NotHispanicOrLatino NotApplicable).includes_none?(@loan.loan_general.government_monitorings.select{|gm| gm.borrower_id == borrower}.map(&:hmda_ethnicity_type)) or
               @loan.loan_general.hmda_races.select{|hm| hm.borrower_id == borrower}.count.eql?(0))
              warnings << 'Government Monitoring information is not complete.'
            end
          end
        end
      end

      # ATLAS-36
      def ltv_80_less_should_not_enter_mi_data_or_monthly_mi_pmnt
        if @loan.ltv.to_f.round(3) <= 80 and @loan.loan_general.proposed_housing_expenses_has_amount_for_type?('MI') and
          (@loan.loan_feature.nil? or !@loan.loan_feature.product_name.starts_with?('FHA'))
           errors << 'LTV is 80% or less. There is a mortgage insurance payment entered in the Proposed housing section. Remove all MI information from the 1003, MI Calc screen and MI screen.'
         end
      end

      # ATLAS-38
      def total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close
        unless @loan.try(:loan_feature).try(:product_name).to_s.include?('IRRL')
          if @loan.loan_general.transaction_detail
            cond = @loan.loan_general.underwriting_conditions.map{|l| l.condition if (l.condition.starts_with?('Maximum approved funds') and l.condition =~ /\d/)}.compact.join
            amnt = cond.scan(/[-+]?\d*\.?\d+/).join
            if amnt.to_d < @loan.loan_general.transaction_detail.total_funds_required_to_close.round(2)
              errors << 'Max funds for closing condition do not reflect sufficient funds for closing.'
            end
          end
        end
      end

      # ATLAS-39
      def liability_account_type_heloc_and_resubordinated_requires_undrawn_heloc_amnt
        if @loan.loan_general.liabilities.map{|l| l.liability_type if l.liability_type.eql?('HELOC') and l.subject_loan_resubordination_indicator}.compact.count > 0 and
          (@loan.loan_general.transaction_detail.nil? or @loan.loan_general.transaction_detail.undrawn_heloc_amount.blank?)
          errors << 'A resubordinated HELOC is entered, verify either full line is drawn or complete undrawn HELOC amount of the details of transaction tab.'
        end
      end

      # ATLAS-40
      def cltv_gt_ltv_requires_proposed_housing_other_financing_gt_zero
        if @loan.cltv.to_f.round(3) > @loan.ltv.to_f.round(3) and 
          !@loan.loan_general.proposed_housing_expenses_has_amount_for_type?('OtherMortgageLoanPrincipalAndInterest')
          warnings << 'If the CLTV is greater than LTV then the proposed Housing Other Financing amount must be greater than 0.00'
        end
      end

      # ATLAS-42
      def other_financing_gt_0_on_proposed_housing_expense_requires_cltv_gt_ltv
        unless @loan.ltv.blank?
          if @loan.loan_general.proposed_housing_expenses_has_amount_for_type?('OtherMortgageLoanPrincipalAndInterest') and
            (@loan.cltv.blank? or @loan.cltv.round(3) <= @loan.ltv.round(3))
            errors << 'Other financing is entered in the Proposed Housing section but subordinate financing is not reflected in the CLTV'
          end
        end
      end
      
      # ATLAS-43
      def occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp
        if @loan.occupancy.in?(%w(Investor SecondHome)) and
          @loan.loan_general.reo_property_current_residence and
          (@loan.loan_general.present_housing_expenses_has_amount_for_type?('HazardInsurance') or
            @loan.loan_general.present_housing_expenses_has_amount_for_type?('RealEstateTax')) and
            @loan.loan_general.reo_property_current_residence.maintenance_expense_amount.to_f <= 0
          errors << 'REO does not have taxes and insurance separate for current residence but Housing expense reflects taxes and insurance broken out.'
        end
      end

      # ATLAS-44
      def occupancy_second_or_investment_and_ins_maint_taxes_not_on_current_housing_expense_then_reo_record_marked_current_must_have_0_for_haz_ins_and_real_est_taxes
        if @loan.occupancy.in?(%w(Investor SecondHome)) and 
          @loan.loan_general.reo_property_current_residence and
          if ((!@loan.loan_general.present_housing_expenses_has_amount_for_type?('HazardInsurance') and 
              !@loan.loan_general.present_housing_expenses_has_amount_for_type?('RealEstateTax')) and
              @loan.loan_general.reo_property_current_residence.maintenance_expense_amount.to_f > 0)
            errors << 'Housing expense does not have taxes and insurance broken out but REO has taxes and insurance separate for current residence.'
          end
        end
      end

      # ATLAS-45
      def occupancy_second_or_investment_requires_p_and_i_be_equal_to_monthly_pmnt
        if @loan.occupancy.in?(%w(Investor SecondHome)) and
          (@loan.loan_general.present_housing_expenses_has_amount_for_type?('FirstMortgagePrincipalAndInterest') or
            @loan.loan_general.present_housing_expenses_has_amount_for_type?('OtherMortgageLoanPrincipalAndInterest')) and
          @loan.loan_general.reo_property_current_residence

          borrowers = @loan.loan_general.borrowers.map(&:borrower_id)
          borrowers.each do |brw|

            first_m_amount =  @loan.loan_general.present_housing_expenses.map {|ph| ph.payment_amount if ph.housing_expense_type.eql?('FirstMortgagePrincipalAndInterest') && ph.borrower_id.eql?(brw)}.compact.map {|v| v if v > 0}.compact.join('')
            other_m_amount =  @loan.loan_general.present_housing_expenses.map {|ph| ph.payment_amount if ph.housing_expense_type.eql?('OtherMortgageLoanPrincipalAndInterest') && ph.borrower_id.eql?(brw)}.compact.map {|v| v if v > 0}.compact.join('')

            heloc_liab = @loan.loan_general.liabilities.map{|l| l.monthly_payment_amount if (l.liability_type.eql?('HELOC') && l.borrower_id.eql?(brw) && @loan.loan_general.reo_property_current_residence.reo_id.eql?(l.reo_id))}.compact.sum
            mortgage_liab = @loan.loan_general.liabilities.map{|l| l.monthly_payment_amount if (l.liability_type.eql?('MortgageLoan') && l.borrower_id.eql?(brw) && @loan.loan_general.reo_property_current_residence.reo_id.eql?(l.reo_id))}.compact.sum

            if (heloc_liab.to_f + mortgage_liab.to_f) != (first_m_amount.to_f + other_m_amount.to_f)
              errors << 'Current residence first mortgage payment on housing expense does not match payment amount for mortgage in liabilities.'
            end

          end
        end
      end

      # ATLAS-46
      def occupancy_second_or_investment_requires_total_of_first_mort_and_other_financing_be_equal_mort_pmnts_on_reo
        if @loan.occupancy.in?(%w(Investor SecondHome)) and
          @loan.loan_general.reo_property_current_residence

          first_m_amount =  @loan.loan_general.present_housing_expenses.map {|ph| ph.payment_amount if ph.housing_expense_type.eql?('FirstMortgagePrincipalAndInterest')}.compact.map {|v| v if v > 0}.compact.join('')
          other_m_amount =  @loan.loan_general.present_housing_expenses.map {|ph| ph.payment_amount if ph.housing_expense_type.eql?('OtherMortgageLoanPrincipalAndInterest')}.compact.map {|v| v if v > 0}.compact.join('')

          unless (first_m_amount.to_d + other_m_amount.to_d == @loan.loan_general.reo_property_current_residence.lien_installment_amount)
            errors << 'Mortgage payments entered in housing expense for current residence do not equal mortgage payments entered in  REO for current residence.'
          end
        end
      end

      # ATLAS-47
      def occupancy_investment_and_purpose_refinance_requires_liability_assoc_to_reo_to_have_property_lien_checked
        if @loan.occupancy.eql?('Investor') and @loan.purpose.eql?('REFINANCE') and
          
          reo_prop = @loan.loan_general.reo_properties.map{|p| p if p.subject_indicator}.compact

          reo_prop.each do |reo|
            heloc_liab = @loan.loan_general.liabilities.map{|l| l if (l.liability_type.eql?('HELOC') and l.reo_id.eql?(reo.reo_id))}.compact
            mortgage_liab = @loan.loan_general.liabilities.map{|l| l if (l.liability_type.eql?('MortgageLoan') and l.reo_id.eql?(reo.reo_id))}.compact

            if (heloc_liab.count > 0 or mortgage_liab.count > 0) and !reo.disposition_status_type.eql?('RetainForRental')
              errors << 'Rental property flag is not checked on mortgage/heloc for the subject property record in the liabilities screen.'
              break
            end
          end
        end
      end

      # ATLAS-49
      def occupancy_investment_or_primary_with_more_than_one_unit_requires_subject_property_net_cash_flow_be_gt_0
        unless @loan.loan_general.try(:transmittal_datum).try(:au_engine_type).eql?('LP')
          if @loan.occupancy.eql?('PrimaryResidence') and (@loan.property and @loan.property.num_of_units.to_i > 1)
            vals =  @loan.loan_general.current_incomes.map {|ci| ci.monthly_total_amount if ci.income_type.eql?('SubjectPropertyNetCashFlow')}.compact
            if vals.length >= 0 && vals.map {|v| v if v != 0}.compact.count.eql?(0)
              errors << 'Subject net cash flow is not completed. If not washing the subject property payment, this field must be completed.'
            end
          end
        end
      end

      # ATLAS-50
      def reo_record_has_property_disposition_of_retained_requires_net_rental_income_be_0_or_null
        if @loan.loan_general.reo_properties.map{|p| p if (p.disposition_status_type.eql?('RetainForPrimaryOrSecondaryResidence') and p.rental_income_net_amount.to_f > 0)}.compact.count > 0
          errors << 'There is a retained REO entered with rental income. Correct either rental income amount or property disposition.'
        end
      end

      # ATLAS-51
      def occupancy_second_or_investment_and_purpose_refinance_requires_reo_must_have_current_subject_indicator_set_to_subject
        if @loan.occupancy.in?(%w(Investor SecondHome)) and @loan.purpose.eql?('REFINANCE') and
          (@loan.loan_general.reo_properties.map{|p| p.subject_indicator if p.subject_indicator}.compact.count.eql?(0))
          errors << 'A REO record has not been entered that is marked subject property.'
        end
      end

      # ATLAS-52
      def occupancy_investment_and_purpose_refinance_requires_reo_record_to_have_property_disposition_of_rental
        if @loan.occupancy.eql?('Investor') and @loan.purpose.eql?('REFINANCE') and
          @loan.loan_general.reo_properties.map{|p| p.subject_indicator if (p.subject_indicator and !p.disposition_status_type.eql?('RetainForRental'))}.compact.count > 0
            errors << 'Subject property is not marked as rental in the REO tab of 1003.'
        end
      end

      # ATLAS-53
      def occupancy_primary_or_secondary_and_purpose_refinance_requires_reo_record_marked_as_subject_or_both_be_marked_as_retained
        if  %w(PrimaryResidence SecondHome).include?(@loan.occupancy) and 
            @loan.purpose.eql?('REFINANCE') and
            (
              @loan.loan_general.reo_properties.map do |p| 
                p if (p.subject_indicator and !p.disposition_status_type.eql?('RetainForPrimaryOrSecondaryResidence'))
              end.compact.count > 0
            )
            errors << 'REO record for subject property must be marked retained'
        end
      end

      # CTMWEB-2057
      def check_property_county
        fips = FipsCodesByCityStateZip.where(city_name: @loan.property_city, state_code: @loan.property_state, zip_code: @loan.property_zip.to_s[0..4])
        fips = fips[0]
        if fips.nil?
          warnings << 'Property County can not be verified for this Property Address. Please verify address validity.'
        elsif @loan.property_county.nil?
          errors << "Property County is not entered. Suggested County name is #{fips.county_name}."
        end
      end

    end
  end
end
