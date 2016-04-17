module InitialDisclosure::WorkQueueHelper

  def disclosure_requested_at loan
    return nil unless loan.initial_disclosure_requested_at
    I18n.l loan.initial_disclosure_requested_at.localtime, format: :full
  end

  def app_date_display loan
    return "missing" unless loan.application_date

    dt = loan.application_date.strftime('%m/%d/%Y')
    if loan.td_property_estimated_value_amount.nil? && loan.td_property_appraised_value_amount.nil?
      dt += " missing estimated value"
    end
    dt
  end
  
  def age_from_date date, end_date = nil
    end_date ||= Date.today
    date.to_date.business_days_until end_date if date.present?
  end

  def is_frp? loan
    return false if loan.property_postal_code.blank?
    FrpZipCode.pluck(:zip_code).include?(loan.property_postal_code[0..4])
  end

  def work_queue_assign_other?
    current_user.is_admin? ||
      current_user.roles.include?("initialdisclosure_assign_reassign")
  end

  def work_queue_self_assign?
    current_user.roles.map(&:downcase).include?("initialdisclosure_selfassign")
  end

  def assignSortType
    return 'dom-select' if work_queue_assign_other?
    'dom-text'
  end

  def work_queue_assign_dropdown loan
    select_tag :wq_status,
      options_for_select(WQ_USERS.map(&:name), loan.initial_disclosure_tracking.try(:assign_to)),
      include_blank: "Unassigned",
      'class' => 'work-queue-assignment-select input-medium', 'data-loannum' => loan.loan_num
  end

  def title_vendor_for loan
    state = loan.property_state_translated
    state_vendor = StateTitleVendor.find_by_state state
    return nil if state_vendor.nil?
    vendor = loan.channel == Channel.wholesale.identifier ? state_vendor.wholesale_vendor : state_vendor.retail_vendor
    vendor.name
  end

  WorkQueueUser = Struct.new(:name, :login)

  WQ_USERS = [
    WorkQueueUser.new('Anderson-Poe, Porsha', 'PoeP'),
    WorkQueueUser.new('Blott, Anna', 'BlottA'),
    WorkQueueUser.new('Brooks, Nathaniel', 'BrooksN'),
    WorkQueueUser.new('Costa, Nicole', 'CostaN'),
    WorkQueueUser.new('Courter, Denise', 'CourterD'),
    WorkQueueUser.new('Creutz, Meagan', 'CreutzM'),
    WorkQueueUser.new('Douglas, Fonda', 'DouglasF'),
    WorkQueueUser.new('Draper, Erick', 'DraperE'),
    WorkQueueUser.new('Dukes, Rhasmeer', 'DukesR'),
    WorkQueueUser.new('Frye, Carrie', 'fryec'),
    WorkQueueUser.new('Garrett, Christi', 'GarrettC'),
    WorkQueueUser.new('Goins, Shameka', 'GoinsS'),
    WorkQueueUser.new('Johnson, Marques', 'johnsonmar'),
    WorkQueueUser.new('Karlek, Charla', 'KarlekC'),
    WorkQueueUser.new('Kotlarczyk, Linsey', 'KotlarczykL'),
    WorkQueueUser.new('LeClaire, Lisa', 'LeClaireL'),
    WorkQueueUser.new('Mayes, Angela', 'MayesA'),
    WorkQueueUser.new('Mullins, Celeste', 'MullinsC'),
    WorkQueueUser.new('Randazzo, Leticia', 'RandazzoL'),
    WorkQueueUser.new('Richards, Jamie', 'richardsj'),
    WorkQueueUser.new('Samaha, Mona', 'SamahaM'),
    WorkQueueUser.new('Schweikert, Amy', 'SchweikertA'),
    WorkQueueUser.new('Shivers, Erica', 'shiverse'),
    WorkQueueUser.new('Smith, Kassidy', 'smithkd'),
    WorkQueueUser.new('Spiker, James', 'SpikerJ'),
    WorkQueueUser.new('Stephens, Ana', 'StephensA'),
    WorkQueueUser.new('Tatus, Kacy', 'TatusK'),
    WorkQueueUser.new('Tylicki, Marianne', 'TylickiM'),
    WorkQueueUser.new('Young, Tara', 'YoungT'),
  ].sort_by &:login

end
