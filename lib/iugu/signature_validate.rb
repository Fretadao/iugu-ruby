module Iugu
  class SignatureValidate < APIResource
    include Iugu::APICreate

    def self.url(_options = nil)
      Iugu.base_uri + "signature/validate"
    end
  end
end
