module Translation
  class LoanServProductCode
    attr_accessor :product_code

    def initialize(product_code)
      self.product_code = product_code
    end

    TRANSLATION =
        {
            'C10/1ARM LIB HIBAL'   => 'CAALH',
            'C10/1ARM LIB RP'      => 'CAALR',
            'C10/1ARM LIBOR'       => 'CAALI',
            'C15FXD FR'            => 'C15FF',
            'C15FXD HIBAL'         => 'C15FH',
            'C15FXD HR'            => 'C15HR',
            'C15FXD RP CD'         => 'C15RC',
            'C15FXD RP'            => 'C15FR',
            'C15FXD'               => 'C15FX',
            'C20FXD FR'            => 'C20FF',
            'C20FXD HIBAL'         => 'C20FH',
            'C20FXD HR'            => 'C20HR',
            'C20FXD RP'            => 'C20FR',
            'C20FXD'               => 'C20FX',
            'C30FXD FR'            => 'C30FF',
            'C30FXD HIBAL'         => 'C30FH',
            'C30FXD HP'            => 'C30HP',
            'C30FXD HR'            => 'C30HR',
            'C30FXD IHDA IL FH'    => 'C30IF',
            'C30FXD IHDA IL'       => 'C30II',
            'C30FXD MCM'           => 'C30FM',
            'C30FXD RP CD'         => 'C30RC',
            'C30FXD RP'            => 'C30FR',
            'C30FXD'               => 'C30FX',
            'C5/1ARM LIB HIBAL'    => 'C5ALH',
            'C5/1ARM LIB RP'       => 'C5ALR',
            'C5/1ARM LIB'          => 'C5ALI',
            'C5/1ARM LIB HR'       => 'C5AHR',
            'C7/1ARM LIB HIBAL'    => 'C7ALH',
            'C7/1ARM LIB RP'       => 'C7ALR',
            'C7/1ARM LIB HR'       => 'C7AHR',
            'C7/1ARM LIB'          => 'C7ALI',
            'C10/1ARM LIB HR'      => 'CAAHR',
            'FHA15FXD'             => 'F15FX',
            'FHA30 IHCDA IN NH'    => 'F30IN',
            'FHA30 IHDA IL FH'     => 'F30IF',
            'FHA30 IHDA IL SM'     => 'F30IS',
            'FHA30 MSHDA NH'       => 'F30MN',
            'FHA30 MSHDA'          => 'F30MS',
            'FHA30FXD'             => 'F30FX',
            'FHA30STR'             => 'F30ST',
            'J10/1ARM LIBOR'       => 'JAALI',
            'J15FXD'               => 'J15FX',
            'J30FXD'               => 'J30FX',
            'J5/1ARM LIB'          => 'J5ALI',
            'J5/1ARM LIBOR'        => 'J5ALB',
            'J7/1 ARM LIB'         => 'J7ALI',
            'MSHDA DPA'            => 'MSHDA',
            'USDA30FXD'            => 'U30FX',
            'VA15FXD'              => 'V15FX',
            'VA30FXD'              => 'V30FX',
            'VA30IRRL'             => 'V30IR',
    }

    def translate
      TRANSLATION[product_code]
    end
  end
end
