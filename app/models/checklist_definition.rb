class ChecklistDefinition

  attr_accessor :sections, :questions, :checklist

  def initialize checklist
    self.checklist = checklist
  end

  @sections = nil
  def sections
    @sections ||= build_sections
  end

  @questions = nil
  def questions
    @questions ||= sections.flat_map(&:questions)
  end

  def loan
    checklist.loan
  end

  def section name
    s = Section.new(name)
    if block_given?
      yield s
    end
    s
  end

  def build_sections
    []
  end

  def fha
    ->(loan) {loan.is_fha?}
  end

  def wholesale
    ->(loan) {loan.channel == Channel.wholesale.identifier}
  end

  def retail
    ->(loan) {loan.channel == Channel.retail.identifier}
  end

  def pb
    ->(loan) {loan.channel == Channel.private_banking.identifier}
  end

  def cd
    ->(loan) {loan.channel == Channel.consumer_direct.identifier}
  end

  def va
    ->(loan) {loan.is_va?}
  end

  def non_irrl_va
    ->(loan) {loan.is_va? && !loan.product_code.to_s.upcase.ends_with?("IRRL")}
  end

  def usda
    ->(loan) {loan.is_usda?}
  end

  def mini_corr
    ->(loan) {loan.mini_corr_loan?}
  end

  def non_mini_corr
    ->(loan) {!loan.mini_corr_loan?}
  end

  def lpmi
    ->(loan) { loan.is_locked? ? loan.lock_loan_datum.try(:lender_paid_mi) : loan.custom_fields.lender_paid_mi? }
  end

  def purchase
    ->(loan) {loan.loan_general.try(:is_purchase?)}
  end

  def refinance
    ->(loan) {loan.loan_general.try(:is_refi?)}
  end

  def flood_zone_x
    ->(loan) {loan.loan_general.flood_determination.try(:nfip_flood_zone_identifier).to_s.upcase.chars.first.in?(['A','V'])}
  end

  def arm_loan
    ->(loan) { loan.try!(:mortgage_term).try!(:loan_amortization_type).eql?("AdjustableRate") }
  end

  class Section
    attr_accessor :name, :questions

    def initialize name
      self.name = name
      self.questions = []
    end

    def question name, options={}
      questions << Question.new(name, options)
    end
  end

  class Question
    attr_accessor :name, :options

    def initialize name, options
      self.name = name
      self.options = options
    end

    def our_attr loan
      return nil unless options[:our_data].present?
      the_data = options[:our_data]
      if the_data[:as] == 'date'
        loan.send(the_data[:our_attr]).nil? ? "" : loan.send(the_data[:our_attr]).strftime('%m/%d/%Y')
      else
        loan.send(the_data[:our_attr])
      end
    end

    def as_json opts={}
      options.merge name: name
    end

    def optional?
      options[:optional] == true
    end

    def applicable_to loan
      thing = options[:applies_to]
      return true if thing.nil?
      return thing if !!thing == thing
      thing.call loan
    end

    def visible? checklist, definition
      conditional_on = options[:conditional_on]
      return true unless conditional_on

      other = definition.questions.find{|q| q.name == conditional_on[:name] }
      raise "could not find conditional target question named #{conditional_on[:name]}" unless other

      return false unless other.visible?(checklist, definition)

      if conditional_on[:presence] == true
        other.answer(checklist).present?
      elsif conditional_on[:equals].present?
        other.answer(checklist) == conditional_on[:equals]
      elsif conditional_on[:one_of].present?
        conditional_on[:one_of].include? other.answer(checklist)
      else
        raise "Unrecognized conditional_on type for question #{name}: #{conditional_on}"
      end
    end

    def has_valid_answer? checklist
      answer(checklist).present?
    end

    def answer(checklist)
      answer_record = checklist.checklist_answers.find {|a| a.name == name }
      answer_record.try(:answer)
    end

  end
  class AppliesToAbstract
    attr_accessor :applies_to_array

    def initialize applies_to_array
      self.applies_to_array = applies_to_array
    end

    def is_bool? val
      val == !!val
    end

  end

  class AppliesToAny < AppliesToAbstract

    def call loan
      applies_to_array.each do |at|
        return true if at.call(loan)
      end
      false
    end

  end

  class AppliesToAll < AppliesToAbstract

    def call loan
      applies_to_array.each do |at|
        return false unless at.call(loan)
      end
      true
    end

  end

end
