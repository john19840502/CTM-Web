require 'spec_helper'

describe "underwriter/checklists/show.haml" do
  before do
    create :uwchecklist_section, is_active: true, column: 1, name: "I should be in right border"
    create :uwchecklist_section, is_active: true, column: 2, name: "I should not be in right border"

    stub_template 'underwriter/checklists/partials/_page_header.haml' => 'h1 Stubbed Page Header'
    stub_template 'uwchecklist_sections/_uwchecklist_section.haml' => '= uwchecklist_section.name'
    stub_template 'underwriter/checklists/partials/_page_footer.haml' => 'h1 Stubbed Page Footer'

    render
  end

  it "should show the correct sections in the right columns" do
    rendered.should have_css('td.right-border') do |right_side|
      right_side.should have_content('I should be in right border')
      right_side.should have_no_content('I should not be in right border')
    end

    rendered.should have_selector('td') do |columns|
      columns.should have_content('I should not be in right border')
    end
  end
end
