require 'exception_formatter'
require_or_load 'servicing/boarding_file_builder'

class Servicing::BoardingFilesController < ApplicationController
  load_and_authorize_resource class: BoardingFile

  def index
    @boarding_files = BoardingFile.includes(:loan_boardings).order("#{BoardingFile.table_name}.created_at DESC").page(params[:page])
  end

  def download_url
    bf = BoardingFile.find(params[:id])
    render text: bf.bundle.url
  end

  def show
    @bf = BoardingFile.find(params[:id])

    @loans = @bf.loans.includes(:boarding_files)
    @total = @loans.inject(0){ |sum, loan| sum += loan.original_balance || 0 }

    respond_to do |format|
      format.csv { render text: export_csv(@bf, @loans) }
      format.html
    end
  end

  def test_one_loan
    unless can? :manage, BoardingFile
      flash[:error] = 'Insufficient permissions'
      redirect_to action: :index and return
    end

    loan = Master::Loan.where(loan_num: params[:loan_num]).first
    text = "Could not find loan with loan_num #{params[:loan_num]}"
      
    if loan
      begin
        bf = BoardingFile.new name: "Test file for loan #{loan.loan_num}"
        bf.board loan
        bf.save!
        text = Servicing::BoardingFileBuilder.new.build bf
      ensure
        bf.destroy unless params[:keep]
      end
    end

    render text: text, :content_type => Mime::TEXT
  end

  def test_loans
    unless can? :manage, BoardingFile
      flash[:error] = 'Insufficient permissions'
      redirect_to action: :index and return
    end

    logger.debug "loan nums #{params[:loan_num].inspect})"
    loans = Master::Loan.where(loan_num: params[:loan_num])
    text = "Could not find any loans with loan_nums #{params[:loan_num]}"
      
    if loans.any?
      begin
        bf = BoardingFile.new name: "Test file for loan numbers #{params[:loan_num].inspect}"
        loans.each { |loan| bf.board loan }
        bf.save!
        text = Servicing::BoardingFileBuilder.new.build bf
      ensure
        bf.destroy unless params[:keep]
      end
    end

    render text: text, :content_type => Mime::TEXT
  end

  private

  def fetch_loans_for_boarding
    LoanBoarding.selected_boarding_loans
  end

  def export_csv bf, loans
    CSV.generate do |csv|
      csv << [ "Loan Num", "Amount", "UPB", "Previously Sent In"]
      loans.each do |loan|
        csv << [
          loan.loan_num,
          view_context.number_to_currency(loan.original_balance),
          view_context.number_to_currency(loan.original_balance),
          other_boarding_file_names(bf, loan)
        ]
      end
    end
  end

  def other_boarding_file_names(bf, loan)
    other_files = loan.boarding_files - [bf]
    return 'Not previously sent' unless other_files.any?
    other_files.map(&:name).join(', ')
  end


end
