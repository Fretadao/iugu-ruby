module Iugu
  class Charge < APIResource
    include Iugu::APICreate

    def success
      @attributes['success'] || false
    end

    def invoice
      return false unless @attributes['invoice_id']
      Invoice.fetch(@attributes['invoice_id'], options)
    end
  end
end
