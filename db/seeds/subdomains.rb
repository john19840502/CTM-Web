subdomains = {
 :admin        => {:label => 'Admin',                 :url => 'http://admin.ctmdev'},
 :ops          => {:label => 'Operations',            :url => 'http://ops.ctmdev'},
 :secmar       => {:label => 'Secondary Marketing',   :url => 'http://secmar.ctmdev'},
 :compliance   => {:label => 'Compliance',            :url => 'http://compliance.ctmdev'},
 :accounting   => {:label => 'Accounting',            :url => 'http://accounting.ctmdev'},
 :hr           => {:label => 'Human Resources',       :url => 'http://hr.ctmdev'},
 # :tss          => {:label => 'TSS',                   :url => 'http://tss.ctmdev'},
 :sales        => {:label => 'Sales',                 :url => 'http://sales.ctmdev'},
 :servicing    => {:label => 'Servicing',             :url => 'http://servicing.ctmdev'},
 :serva        => {:label => 'Servicing Acquisition', :url => 'http://serva.ctmdev'},
 :risk         => {:label => 'Risk Management',       :url => 'http://risk.ctmdev'},
 :credit       => {:label => 'Credit Risk',           :url => 'http://credit.ctmdev'},
 :closing      => {:label => 'Closing',               :url => 'http://closing.ctmdev'},
 :postclosing  => {:label => 'Post Closing',          :url => 'http://postclosing.ctmdev'},
 :lockdesk     => {:label => 'Lock Desk',             :url => 'http://lockdesk.ctmdev'},
 :pac          => {:label => 'PAC',                   :url => 'http://pac.ctmdev'},
 :uw           => {:label => 'Underwriter',           :url => 'http://uw.ctmdev'},
 :bpm          => {:label => 'Business Project Mgmt', :url => 'http://bpm.ctmdev'}
}

subdomains.keys.each do |key|
   
   Subdomain.find_or_create_by_name(key.to_s, :label => subdomains[key][:label])
   
end