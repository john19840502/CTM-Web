module Registration::ForcedRegistrationsHelper
  def build_reassign_form(loan)
    can_reassign = user_roles.include?("forced_registration_reassign")
    can_self_assign = user_roles.include?("forced_registration_self_assign")
    render partial: "assignee", locals: {:loan => loan, :users => REGISTRATION_USERS, :can_reassign => can_reassign, :can_self_assign => can_self_assign}, formats: [:html]
  end

  def build_loan_disclosure_warning(loan)
    "#{loan.loan_num} <span class='fa fa-exclamation' title='Loan Intent to Proceed Date before Disclosure Date'></span>" 
  end

  def build_comments_table(loan)
    render partial: "comments_table", locals: {loan: loan}, formats: [:html]
  end

  def build_child_row(loan)
    render partial: "user_action_form", locals: {loan: loan}, formats: [:html]
  end

  def build_actions_select
    select_tag :user_action, options_for_select(USER_ACTIONS), {}
  end

  USER_ACTIONS = ['Select an Action', 'Contacted LO', 'Consent Withdrawn', 'Submitted to File Incomplete', 'Submitted to Registration']

  RegistrationQueueUser = Struct.new(:name, :login)

  REGISTRATION_USERS = [
    RegistrationQueueUser.new('Anderson-Poe, Porsha', 'PoeP'),
    RegistrationQueueUser.new('Brennan-Key, Alice', 'KeyA'),
    RegistrationQueueUser.new('Brooks, Nathaniel', 'BrooksN'),
    RegistrationQueueUser.new('Costa, Nicole','CostaN'),
    RegistrationQueueUser.new('Douglas, Fonda','DouglasF'),
    RegistrationQueueUser.new('Draper, Erick','DraperE'),
    RegistrationQueueUser.new('Dukes, Rhas', 'DukesR'),
    RegistrationQueueUser.new('Garrett, Christi', 'GarrettC'),
    RegistrationQueueUser.new('Goins, Shameka', 'GoinsS'),
    RegistrationQueueUser.new('Grayum, Dawn', 'GrayumD'),
    RegistrationQueueUser.new('Johnson, Marques', 'Johnsonmar'),
    RegistrationQueueUser.new('Kotlarcyk, Linsey', 'KotlarckL'),
    RegistrationQueueUser.new('LeClaire, Lisa', 'LeClaireL'),
    RegistrationQueueUser.new('Mayes, Angela', 'MayesA'),
    RegistrationQueueUser.new('Richards, Jamie', 'richardsj'),
    RegistrationQueueUser.new('Shivers, Erica', 'shiverse'),
    RegistrationQueueUser.new('Smith, Kassidy', 'smithkd'),
    RegistrationQueueUser.new('Stephens, Ana', 'StephensA'),
    RegistrationQueueUser.new('Tatus, Kacy', 'TatusK'),
    RegistrationQueueUser.new('Teichman, Ernest', 'TeichmanE'),
    RegistrationQueueUser.new('Tylicki, Marianne', 'TylickiM'),
  ].sort_by &:login

end
