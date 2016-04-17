module Esign::BorrowerWorkQueueHelper

  ALL_ASSIGNABLE_USERS =[
      "Anderson-Poe, Porsha",
      "Brennan-Key, Alice",
      "Brooks, Nathaniel",
      "Brothers, Kimberly",
      "Costa, Nicole",
      "Douglas, Fonda",
      "Draper, Erick",
      "Dukes, Rhas",
      "Garrett, Christi",
      "Goins, Shameka",
      "Grayum, Dawn",
      "Johnson, Marques",
      "Kotlarczyk, Linsey",
      "LeClaire, Lisa",
      "Mayes, Angela",
      "Richards, Jamie",
      "Shivers, Erica",
      "Smith, Kassidy",
      "Stephens, Ana",
      "Tatus, Kacy",
      "Teichman, Ernest",
      "Tylicki, Marianne"
    ]

  ALL_REASSIGN_USERS = [
      "Blott, Anna",
      "Courter, Denise",
      "Karlek, Charla",
      "Randazzo, Leticia",
      "Samaha, Mona",
      "Spiker, Jim",
      "Young, Tara"
    ]

  def assignable_users
    if is_assigner?
      ALL_ASSIGNABLE_USERS + ALL_REASSIGN_USERS
    elsif is_assignable?
      [current_user_name]
    else
      []
    end
  end

  def can_edit?
    is_assignable? || is_assigner?
  end

  private

  def is_assignable?
    @assignable ||= user_roles.include?("forced_registration_self_assign")
  end

  def is_assigner?
    @assigner ||= user_roles.include?("forced_registration_reassign")
  end

  def current_user_name
    "#{current_user.last_name}, #{current_user.first_name}"
  end

end
