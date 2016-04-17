module Esign

  class EventListingsController < RestrictedAccessController

    def index
    end

    def search
      date_string, loan_number = clean_params params

      request = request_for date_string, loan_number
      response = request.execute
      Rails.logger.info response #SWITCH BACK TO DEBUG!
      if @search_term == loan_number
        @search_type = "Loan"
        @event_listings = response.listings.reverse
      elsif @previous_date.nil? && @next_date.nil?
        @search_type = "Date Range"
        @event_listings = DocMagic::Filter.by_most_recent_package_version(response.listings)
      else
        @search_type = "Date"
        @event_listings = response.listings
      end
    end

    private

    def request_for date_string, loan
      loan ? loan_request(loan) : date_request(date_string)
    end

    def clean_params params
      [filter_undefined(params[:start_date]), filter_undefined(params[:loan_num])]
    end

    def loan_request loan
      @search_term = loan
      DocMagic::EventListingRequest.for_loan_num loan
    end

    def date_request date_string
      date_string.blank? ? request_for_range(25.days.ago, Time.now) : request_for_date(date_string)
    end

    def request_for_date date_string
      d = date_string.to_time
      @previous_date = calculate_previous_day d
      @next_date = calculate_next_day d
      @search_term = format_date d
      DocMagic::EventListingRequest.for_date d
    end

    def request_for_range start_date, end_date
      @search_term = "#{format_date(start_date)} - #{format_date(end_date)}"
      DocMagic::EventListingRequest.for_date_range start_date, end_date
    end

    def calculate_previous_day dt
      format_date(dt - 1.day)
    end

    def calculate_next_day dt
      next_day = dt + 1.day
      Time.zone.now < next_day ? nil : format_date(next_day)
    end

    def format_date datetime
      datetime.strftime("%m/%d/%Y")
    end

    def filter_undefined value
      value == "undefined" || value.blank? ? nil : value
    end

  end

end