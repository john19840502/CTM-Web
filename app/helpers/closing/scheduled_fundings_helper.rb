module Closing
  module ScheduledFundingsHelper
    def note_last_updated_by_search_column(record, input_name)
      select :record, :note_last_updated_by, options_for_select(CtmUser.user_names), {:include_blank => as_(:_select_)}, input_name
    end

    def scheduled_funding_channel_column(record)
      record.channel.to_s[0..1]
    end

    def channel_search_column(record, input_name)
      select :record, :channel, options_for_select(ScheduledFunding.channel_options), {:include_blank => as_(:_select_)}, input_name
    end
  end
end