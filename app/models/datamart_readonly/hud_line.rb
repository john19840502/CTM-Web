class HudLine < DatabaseDatamartReadonly
  belongs_to  :loan_general
  has_many    :paid_by_fees

  scope :paid_by_borrower, -> { where{paid_by.in ['Borrower', 'Multiple']} }

  CREATE_VIEW_SQL = <<-eos
      SELECT   HUD_LINE_id            AS id,
               loanGeneral_Id         AS loan_general_id,
               _AdditionalAmount      AS additional_amt,
               _DailyAmount           AS daily_amt,
               _LineNumber            AS line_num,
               _MonthlyAmount         AS monthly_amt,
               _NumberOfDays          AS num_days,
               _NumberOfMonths        AS num_months,
               _PaidBy                AS paid_by,
               _PaidTo                AS paid_to,
               _RatePercent           AS rate_perc,
               _SystemFeeName         AS sys_fee_name,
               _TotalAmount           AS total_amt,
               _UserDefinedFeeName    AS user_def_fee_name,
               FeeCategory            AS fee_category,
               NetFeeIndicator        AS net_fee_indicator,
               hudType                AS hud_type
      FROM       LENDER_LOAN_SERVICE.dbo.[HUD_LINE]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.hud
    where(hud_type: 'HUD')
  end

  def self.gfe
    where(hud_type: 'GFE')
  end

  def self.by_hud_line(num)
    where(hud_type: 'HUD', line_num: num)
  end

  def self.by_fee_name(fee_name)
    where{sys_fee_name.like fee_name}
  end

  def self.hud_line_value(fee_name, column = :total_amt)
    by_fee_name(fee_name).first.try(column).to_f
  end

  def self.hud_line_value_pre_trid(num, fee_name)
    by_hud_line(num).by_fee_name(fee_name).first.try(:total_amt).try(:to_f)
  end

  def self.hud_line_value_and_paid_by_fee(fee_name)
    paid_by_borrower_only(by_fee_name(fee_name).paid_by_borrower)
  end

  def self.hud_map_value(range)
    self.all.map{|l| l.hud_value(range)}.compact.sum
  end

  def self.hud_ary_value(range, fee_ary)
    self.all.map{|l| l.hud_ary(range, fee_ary)}.compact.sum
  end

  def self.with_category cat, fee_names
    where(fee_category: cat).where{sys_fee_name.in fee_names}.map(&:total_amt).compact.sum
  end

  def self.with_category_and_paid_by_fee cat, fee_names
    paid_by_borrower_only(self.where(fee_category: cat).where{sys_fee_name.in fee_names})
  end

  def self.with_category_and_paid_to cat, paid_to
    self.where(fee_category: cat, paid_to: paid_to)
  end

  def self.with_category_and_fee_name_start_with(cat, fee_name_start_with, column = :total_amt)
    where(fee_category: cat).where{sys_fee_name.like "#{fee_name_start_with}%"}.map(&column).compact.sum
  end

  def self.with_category_and_fee_name_start_with_and_paid_by_fee(cat, fee_name_start_with, column = :total_amt)
    paid_by_borrower_only(self.where(fee_category: cat).where{sys_fee_name.like "#{fee_name_start_with}%"})
  end

  def hud_range(range)
    hud_type.eql?('HUD') and (range).include?(line_num)
  end

  def hud_value(range)
    total_amt if hud_range(range)
  end

  def hud_ary(range, fee_ary)
    total_amt if hud_range(range) and fee_ary.include?(sys_fee_name)
  end

  def self.paid_by_borrower_only huds
    tot_fee = 0
    huds.each do |h|
      tot_fee += h.total_amt.to_f if h.paid_by.eql?('Borrower')
      tot_fee += h.paid_by_fees.where(paid_by_type: "Borrower").last.try(:pay_amount).to_f
    end
    return tot_fee
  end
end
