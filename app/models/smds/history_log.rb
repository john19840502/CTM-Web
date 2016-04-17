module Smds
  class HistoryLog < ::DatabaseDatamart
    self.table_name_prefix += 'smds_'

    CREATE_VIEW_SQL = <<-eos
        SELECT LogID            AS id,
               ProcessMonitored AS process_monitored,
               StatusMessage    AS status_message,
               DateTimeStarted  AS started_at,
               DateTimeEnded    AS ended_at
        FROM CTM.smds.SMDSHistoryLog
    eos

    def self.sqlserver_create_view
      CREATE_VIEW_SQL
    end
  end
end
