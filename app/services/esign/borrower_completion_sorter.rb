module Esign

  class BorrowerCompletionSorter
    include ServiceObject

    attr_accessor :queue_records

    def initialize queue_records
      self.queue_records = queue_records
    end

    def call 
      default_sort
    end

    private

    def default_sort 
      queue_records.sort{|a, b| loan_ascending(a,b)}.chunk{|qr| qr.loan_number}.map{|ln, arr| arr.sort{|a, b| date_ascending(a,b)} }.sort{|a, b| min_date_ascending(a, b)}.flatten
    end

    def loan_ascending a, b
      a.loan_number <=> b.loan_number
    end

    def min_date_ascending a, b
      date_ascending min_date(a), min_date(b)
    end

    def min_date arr
      arr.min_by{|a| completed_date(a)}
    end

    def date_ascending a, b
      completed_date(a) <=> completed_date(b)
    end

    def same_loan? a, b
      a.loan_number == b.loan_number
    end

    def completed_date record
      record.esign_signer.esign_completed_date
    end

  end

end