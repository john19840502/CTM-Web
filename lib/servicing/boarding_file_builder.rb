require 'fi_serv_loan'
require 'servicing/card_deck_builder'

module Servicing
  class BoardingFileBuilder

    attr_accessor :progress_sink, :translator_factory

    def initialize progress_sink=nil, xf = nil
      self.progress_sink = progress_sink
      self.translator_factory = xf || NormalTranslatorFactory.new
    end

    class NormalTranslatorFactory
      def build_translator_for(loan)
        FiServLoan.new loan
      end
    end

    def build boarding_file
      count = boarding_file.loans.size
      elements = [header]
      boarding_file.loans.each_with_index do |loan, i|
        Rails.logger.debug "writing loan number #{loan.loan_num} to boarding file"
        #TODO: maybe notify progress less often if there are lots of loans?
        notify_progress 100*i/count
        translated_loan = translator_factory.build_translator_for(loan)
        cdb = CardDeckBuilder.new(translated_loan)
        elements << cdb.card_deck.to_s.chomp
      end

      elements.join "\r\n"
    end

    def header
      "  1#{DateTime.now.strftime('%y%m%d%H:%M:%S')}02" + ' '*61
    end

    private

    def notify_progress percent
      return unless progress_sink
      progress_sink.notify percent
    end

  end


end
