##################################################################
## Smds::UlddMethods contains methods used in all ULDDs.. FNMA, FHLB and FHLMC 
##################################################################

module Smds
  module UlddMethods

    def HMDARateSpreadPercent
      return format_num(self.APRSprdPct, 2) if self.APRSprdPct > 1.5 
      ''
    end

  end
end