require 'net/sftp'
require 'servicing/boarding_file_builder'

desc "Generate nightly LOI file"
task :build_loi => :environment do
  abort('Only works in production.') unless Rails.env == 'production'
  success   = false
  bf_result = ''
  bf = nil
  begin
    loans = Master::Shipping.available_for_boarding.map(&:loan)
    loans.concat(Master::LoanDetails::CustomLoanData.where(force_boarding: true).map(&:loan))
    # set these back to 0 so they are not boarded again
    Master::LoanDetails::CustomLoanData.update_all(force_boarding: false) 
    bf = BoardingFile.new name: "LOI File - #{DateTime.now.strftime('%m/%d/%Y')}"
    loans.each {|l| bf.board l}
    bf.save!
    bf_result = Servicing::BoardingFileBuilder.new.build bf
    success = bf_result.present? ? true : false
    if success
      # save file
      filename = "#{Rails.env}_LOI_#{DateTime.now.to_i}.txt"
      path = File.join(Rails.root, 'tmp', 'servicing', filename)
      FileUtils.mkdir_p(File.dirname(path)) unless File.exist?(File.dirname(path))
      File.open(path, 'w') {|file| file.write(bf_result) }
      bf.update_attribute(:bundle, File.open(path, 'r'))
      FileUtils.rm(path)
    end
  rescue Exception => e
    success = false
    puts e.inspect
    Rails.logger.error e.inspect
  end
  notify_loi(loans, bf, {success: success, msg: e.inspect})
  Rake::Task["send_loi"].invoke(bf.bundle.path) if success && loans.size > 0
end

desc "FTP Todays LOI File" 
task :send_loi, [:filename] => :environment do |t, args|
  abort('Only works in production.') unless Rails.env == 'production'
  success       = false
  local_file    = args[:filename]
  prod_filename = "ORIG834.#{DateTime.now.strftime('%m%d%y%H%M%S')}"
  test_filename = "TEST.ORIG834.#{DateTime.now.strftime('%m%d%y%H%M%S')}"
  remote_file   = Rails.env == 'production' ? prod_filename : test_filename
  puts "SENDING LOI FILE #{local_file} - #{remote_file}"
  begin
    seconds_to_retry ||= [10, 30, 45, 60, 120, 300] 
    SFTP_HOST = Rails.env.development? ? 'localhost' : 'mvt.mortgageserv.com'
    Net::SFTP.start(SFTP_HOST, 'ctmtg', password: 'unf4djX@') do |sftp|
      if sftp.upload!(local_file, "Inbound/#{remote_file}")
        success = true
        msg     = ''
      end
    end
  rescue Exception => e 
    if seconds = seconds_to_retry.shift
      Rails.logger.error "LOI UPLOAD FAILED. RETRYING IN #{seconds} SECONDS"
      Rails.logger.error e.inspect
      sleep(seconds) 
      retry
    else
      success   = false
      msg       = e.inspect
      Rails.logger.error "LOI UPLOAD FAILED AFTER 6 RETRIES"
      Rails.logger.error e.inspect
    end
  end
  Email::Postman.call Notifier.loi_file_status(success, msg)
end


def notify_loi(loans, boarding_file, options = {})
  if options[:success]
    Email::Postman.call Notifier.loi_file_generation(loans, true)
    Email::Postman.call Notifier.loi_file_report_link(boarding_file)
  else
    Email::Postman.call Notifier.loi_file_generation(loans, false, options[:msg])
  end
end
