class Accounting::CommissionPlanDetailsController < RestrictedAccessController
  load_and_authorize_resource
  
  def index
    if params[:title].present?
      data.model = CommissionPlanDetail.joins{ datamart_user_profiles.branch }.
                                        where{ (datamart_user_profiles.branch.channel.in Channel.retail_all_ids) }.
                                        order('is_active desc, last_name asc').
                                        select("#{CommissionPlanDetail.table_name}.*, #{Institution.table_name}.id as branch_id, #{Institution.table_name}.institution_number")

                                        #includes(:current_compensation_details_list => { :branch_compensation => :current_packages}).
      
      search_title = UserProfile::ACCOUNTING_TITLES[params[:title].to_i]

      data.model = data.model.where{ datamart_user_profiles.title == search_title }

    else
      data.model = CommissionPlanDetail.from_retail_or_cd_branches.
                                        includes(:datamart_user_profiles, :current_compensation_details_list => { :branch_compensation => :current_packages}).                                      
                                        order('is_active desc, last_name asc').
                                        select("#{CommissionPlanDetail.table_name}.*, #{Institution.table_name}.id as branch_id, #{Institution.table_name}.institution_number")

    end

    data.label = 'Commission Plan Details'

    data.columns = [
      :branch_id,
      :institution_number,
      :active,
      :commission_plan_date, 
      :ultipro_emp_id, 
      :profile_title, 
      :preferred_first_name,
      :fixed_first_name, 
      :last_name, 
      # :supervisor,
      :location, 
      :traditional_split, 
      :tiered_split_low,
      :tiered_split_high,
      :tiered_amount,
      :lo_min,
      :lo_max,
      :amount_per_loan,
      :amount_per_branch,
      :bsm_override,
      :bmsf_override
    ]
    respond_to do |format|
      format.html
      format.xls { @records = data.model }
    end
  end

end
