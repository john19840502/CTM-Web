module Admin::SubdomainsHelper
  def navigations_column(record)
    output = record.navigations.roots.map{|r| r.name}.join(', ')
    output.blank? ? 'Create New' : output
  end
end
