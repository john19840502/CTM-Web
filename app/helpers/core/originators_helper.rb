module Core::OriginatorsHelper
  def header hdr
    html = "<div class='lead'>"
    
    html << "#{link_to_if can?(:read, Institution), "Branch #{hdr.branch_name} :: #{hdr.institution_number}", core_institution_path(hdr)} " if hdr.present?

    html << "#{Channel.retail.name}, #{Channel.private_banking.name} and #{Channel.consumer_direct.name} Branch Employees"

    html << "</div>"

    html
  end
end
