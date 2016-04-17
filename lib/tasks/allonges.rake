namespace :ctm  do

  desc "Create allonges from a file argument" 
  task :create_allonges, [ :file ] => :environment do |t, args| 
    puts "file is #{args.file}" 
    input = AllongeInput.new(args.file)
    puts "ids: #{input.ids}"
    loans = Master::Loan.where(loan_num: input.ids)
    puts "#{loans.size} loans"
    controller = AllongeController.new
    report = controller.string_report loans, input.successors
    File.open("#{Rails.root}/tmp/allonges.pdf", "wb") {|file| file.write report}
  end

  class AllongeInput
    attr_reader :rows, :successors, :ids
    def initialize(filename)
      @rows = []
      @ids = []
      @successors = {}

      parse_file(filename)
    end

    private
    def parse_file(filename)
      first = true
      file = File.open(filename, 'r')
      SpreadsheetParser.parse(file) do |row| 
        if first
          first = false
          next
        end

        id = row.first.to_i
        successor = row.drop(1).first

        self.rows << row 
        self.ids << id
        self.successors[id.to_s] = successor
      end
    end
  end

end

