module Admin::NavigationsHelper
  # def roles_column(record, column)
  #   record.roles.map{|r| r.name}.sort.join(', ')
  # end

  def role_list_form_column(record, column)
    # collection_select(:record, :roles, Role.all, :name, :label, prompt: true, multiple: true)
    select_tag :record_role_taggings, options_for_select(Role.all.collect {|r| [r.label, r.name]}, record.role_list), multiple: true, size: 10, name: '[record][role_list][]'
  end
end
