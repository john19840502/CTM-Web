class SettlementAgentAuditOccurance

  # occ_cal represents the Question's each occurance of wrong needs to be counted or not. If it is false only one occurrence of wrong answer is counted.
  # hud: defines if the hud_review is counted for the particular question. If yes each time question is wrong hud review is counted

  def initialize(agent_audit, questions)
    @agent_audit = agent_audit
    @questions = questions
    @hud_count = false
  end

  def call 
    @questions.each do |key, value|
      #  Sub questions will be executed in do_checks
      do_checks(key, value) unless value[:checks].empty?
      if !@agent_audit[key.to_sym].nil? && @agent_audit[key.to_sym] != value[:expected] && value[:checks].empty?
        if value[:occ_cal] || (@agent_audit["#{key}_occurance".to_sym].to_i == 0 )
          increment_occurance key
          @hud_count = true if value[:hud]
        end
        # No calculation required when it changes from Wrong to expected answer
      end 
    end
    @agent_audit[:hud_review] = @agent_audit[:hud_review] + 1 if (@agent_audit[:hud_review] == 0 || @hud_count)
      
    @agent_audit.save
  end

  private
  
  def increment_occurance key_for
    @agent_audit["#{key_for}_occurance".to_sym] = @agent_audit["#{key_for}_occurance".to_sym] + 1
  end

  # Audit main questions are Valid or not is calculated based on the sub questions listed
  def do_checks agent_page, values
    @agent_audit["#{agent_page}".to_sym] = values[:expected]

    values[:checks].each do |sub_ques, check_value|
      if !@agent_audit[sub_ques.to_sym].nil? && !@agent_audit[sub_ques.to_sym].in?(check_value)
        increment_occurance sub_ques
        # increment_occurance agent_page # To add on to Agent Page errors
        @agent_audit["#{agent_page}_count".to_sym] = @agent_audit["#{agent_page}_count".to_sym] + 1
        @agent_audit["#{agent_page}".to_sym] = values[:unexpected]
        @hud_count = true if values[:hud]
      end
    end
  end
end