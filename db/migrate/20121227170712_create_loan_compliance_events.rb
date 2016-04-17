class CreateLoanComplianceEvents < ActiveRecord::Migration
  def change
    create_table :loan_compliance_events do |t|

      t.integer :aplnno
      t.string :appname
      t.string :propstreet
      t.string :propcity
      t.string :propstate
      t.string :propzip
      t.date   :apdate
      t.integer :lntype
      t.integer :proptype
      t.integer :lnpurpose
      t.integer :occupancy
      t.integer :lnamount
      t.integer :preappr
      t.integer :action
      t.date :actdate
      t.integer :apeth
      t.integer :capeth
      t.integer :aprace1
      t.integer :aprace2
      t.integer :aprace3
      t.integer :aprace4
      t.integer :aprace5
      t.integer :caprace1
      t.integer :caprace2
      t.integer :caprace3
      t.integer :caprace4
      t.integer :caprace5
      t.integer :apsex
      t.integer :capsex
      t.integer :tincome
      t.integer :purchtype
      t.integer :denialr1
      t.integer :denialr2
      t.integer :denialr3
      t.string :apr
      t.string :spread
      t.date :lockdate
      t.integer :loan_term
      t.integer :hoepa
      t.integer :lienstat
      t.string :qltychk
      t.date :createdate
      t.integer :channel
      t.datetime :finaldate
      t.integer :initadjmos
      t.string :apptakenby
      t.string :occupyurla
      t.integer :branchid
      t.string :branchname
      t.integer :loanrep
      t.string :loanrepname
      t.string :note_rate
      t.string :pntsfees
      t.integer :broker
      t.string :brokername
      t.string :ltv
      t.string :cltv
      t.string :debt_ratio
      t.string :comb_ratio
      t.integer :apcrscore
      t.integer :capcrscore
      t.integer :penalty
      t.string :loan_prog
      t.integer :marital
      t.integer :maritalc
      t.string :apl_age
      t.integer :co_apl_age
      t.integer :cash_out
      t.integer :doc_type
      t.integer :amort_term
      t.string :amorttype
      t.integer :apprvalue
      t.string :lender_fee
      t.string :broker_fee
      t.string :orig_fee
      t.integer :disc_pnt
      t.string :dpts_dl
      t.string :houseprp
      t.string :mnthdebt

      t.timestamps
    end
  end
end
