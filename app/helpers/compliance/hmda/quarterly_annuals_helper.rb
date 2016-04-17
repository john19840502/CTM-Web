module Compliance::Hmda::QuarterlyAnnualsHelper
  def transform_button
    # if LoanComplianceEvent.where(transformed: false).count > 0
      link_to "Do Transformations", transform_compliance_hmda_quarterly_annuals_path, :class => 'btn btn-danger'
    # else
    #   button_tag "Do Transformations", :class => 'btn btn-danger disabled'
    # end
  end
end