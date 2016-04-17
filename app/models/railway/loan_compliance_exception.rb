class LoanComplianceException

  attr_accessor :range, :range2, :params, :user

  #caller will do: exception = LoanComplianceException.new(range, range2, params, user).import_cra_wiz

  def initialize(range, range2, params, user)
    @range, @range2, @params, @user = range, range2, params, user
  end

  def uniq_aplnno
    range.pluck(:aplnno).uniq
  end

  def scoped_range
    range2.all
  end 

  def find_aplnno(l)
    ex2 = scoped_range
    ex2.where(:aplnno => l) if ex2.where(:aplnno => l).count > 1
  end 

  def import_cra_wiz
    ex = uniq_aplnno    
    ex.map do |l|
      find_aplnno(l)
    end.compact.flatten
  end

  def map_columns(l)
    hsh = []
    COLUMNS.each do |col|
      hsh << { col => l.map(&col).uniq }
    end
    hsh
  end

  def compare_periods   
    ln = import_cra_wiz
    ln.group_by(&:aplnno).map do |i, l|
      map_columns(l)
    end
  end

  def event_aplnno
    LoanComplianceEvent.where(:aplnno => params[:aplnno])
  end

  def attr_present(attr_name)
    params[attr_name.to_sym].present? and !attr_name.eql?('id')
  end

  def send_attr_name(le, attr_name)
    le.send("#{attr_name}=", params[attr_name.to_sym])
  end

  def update_attr(a, le)
    attr_name = a[0]
    if attr_present(attr_name)
      send_attr_name(le, attr_name)
    end 
  end

  def update_loan_event(le)
    le.attributes.each do |a|
      update_attr(a, le)
    end
      
    le.exception_history = le.changes
    le.reconciled_by = "#{user.display_name}"
    le.reconciled_at = Time.now

    le.save!
  end

  def update_cra_wiz   
    event_aplnno.each do |le|
      update_loan_event(le)
    end
  end

  COLUMNS = [
    :actdate,
    :action_code,
    :amort_term,
    :amorttype,
    :apdate,
    :apeth,
    :aplnno,
    :appname,
    :apptakenby,
    :apr,
    :aprace1,
    :aprace2,
    :aprace3,
    :aprace4,
    :aprace5,
    :apsex,
    :capeth ,
    :caprace1,
    :caprace2,
    :caprace3,
    :caprace4,
    :caprace5,
    :capsex,
    :censustrct,
    :cntycode,
    :denialr1,
    :denialr2,
    :denialr3,
    :initadjmos,
    :lnamount,
    :lnpurpose,
    :lntype,
    :loan_prog,
    :loan_term,
    :macode,
    :occupancy,
    :preappr,
    :propcity,
    :propstate,
    :propstreet,
    :proptype,
    :propzip,
    :purchtype,
    :stcode,
    :tincome
  ]

end
