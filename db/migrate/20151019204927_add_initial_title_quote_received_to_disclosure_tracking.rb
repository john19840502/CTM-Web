class AddInitialTitleQuoteReceivedToDisclosureTracking < ActiveRecord::Migration
  def change
    add_column :initial_disclosure_trackings, :initial_title_quote_received, :boolean
  end
end
