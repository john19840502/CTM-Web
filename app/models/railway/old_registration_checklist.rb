class OldRegistrationChecklist < DatabaseRailway
  self.table_name = "ctmweb_registration_checklists_#{Rails.env.downcase}"
end