module Servicing::BoardingFilesHelper

  def other_boarding_files loan, bf
    other_files = loan.boarding_files - [bf]
    return 'Not previously sent' unless other_files.any?
    content_tag(:ul, class: 'list') do
      other_files.each do |boarding_file|
        concat(content_tag(:li) do
          concat link_to(boarding_file.name, servicing_boarding_file_path(boarding_file))
        end)
      end
    end
  end

end
