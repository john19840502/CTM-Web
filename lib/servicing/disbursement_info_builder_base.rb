
module Servicing
  class DisbursementInfoBuilderBase
    attr_accessor :loan
    
    def initialize(loan)
      self.loan = loan
    end

    def build_info
      return unless hud_line && disbursement

      Fiserv::EscrowDisbursementInfo.new(name).tap do |info|
        info.date = date
        info.expiration_date = expiration_date
        info.months = payment_months
        info.count = count
        info.type = mapped_type
        info.type_qualifier = qualifier
        info.amount = amount
        info.payee_code_prefix = payee_code_prefix
        info.payee_code_suffix = payee_code_suffix
        info.certificate_identifier = certificate_identifier
        info.coverage_code = coverage_code
      end
    end

    def net_fee_indicator
      hud_line.try(:net_fee_indicator)
    end

    protected

    def name
      disbursement_name.underscore
    end

    def disbursement_name
      raise 'derived classes must implement this'
    end

    def hud_line_num
      raise 'derived classes must implement this'
    end

    def system_fee_name
      raise 'derived classes must implement this'
    end

    def escrow_item_type
      raise 'derived classes must implement this'
    end

    def type
      raise 'derived classes must implement this'
    end

    def qualifier
      raise 'derived classes must implement this'
    end

    def mapped_type
      if net_fee_indicator
        return type
      else
        case type
        when 'Z'
          return 1
        when 'H'
          return 2
        when 'P'
          return 4
        when 'R'
          return 6
        when 'T'
          return 9
        when 'E'
          return 8
        else
          return type
        end 
      end
    end

    def payee_code_prefix
      '0999'
    end

    def payee_code_suffix
      '09991'
    end

    def expiration_date
      nil
    end

    def certificate_identifier
      999_999_991
    end

    def coverage_code
      ' '
    end


    private

    def hud_line
      @hud_line ||= loan.hud_lines.find do |hl|
        hl.hud_type == 'HUD' &&
          right_kind_of_hud_line?(hl) &&
          hl.monthly_amount.to_f > 0
      end
    end

    def right_kind_of_hud_line? hl
      if loan.trid_loan?
        hl.system_fee_name == system_fee_name
      else
        hl.line_num == hud_line_num
      end
    end

    def disbursement
      @disbursement ||= find_disbursement if hud_line.present?
    end

    def find_disbursement
      loan.escrows.find do |escrow| 
        right_kind_of_escrow?(escrow) && 
          escrow.collected_number_of_months_count == hud_line.num_months
      end
    end

    def right_kind_of_escrow? escrow
      if loan.trid_loan?
        escrow.item_type.downcase == escrow_item_type.downcase
      else
        escrow.item_type.downcase == disbursement_name.downcase
      end
    end

    def disbursement_event
      @event ||= loan.escrow_disbursement_types.find do |edt|
        edt.disbursement_type.downcase == disbursement_name.downcase
      end
    end

    def amount
      annual_amount = hud_line.monthly_amount * 12
      return annual_amount / count.to_f if count.present?
      annual_amount
    end

    def count
      case disbursement.try(:payment_frequency_type)
      when 'Monthly' then 12
      when 'Quarterly' then 4
      when 'Annual' then 1
      when 'SemiAnnual' then 2
      when 'TriAnnual' then 3
      else 12
      end
    end

    def date
      disbursement.due_date.try(:to_date)
    end

    def payment_months
      return [ 0, 0, 0, 0 ] if count == 12
      return nil unless date

      return [
        disbursement.due_date.try(:to_date).try(:month) || 0,
        disbursement.second_due_date.try(:to_date).try(:month) || 0,
        disbursement.third_due_date.try(:to_date).try(:month) || 0,
        disbursement.fourth_due_date.try(:to_date).try(:month) || 0 ]
    end
  end
end
