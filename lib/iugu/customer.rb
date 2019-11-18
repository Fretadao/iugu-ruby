module Iugu
  class Customer < APIResource
    include Iugu::APIFetch
    include Iugu::APICreate
    include Iugu::APISave
    include Iugu::APIDelete

    def payment_methods
      APIChildResource.new({ customer_id: self.id }, Iugu::PaymentMethod, options)
    end

    def invoices
      APIChildResource.new({ customer_id: self.id }, Iugu::Invoice, options)
    end

    def default_payment_method
      return false unless @attributes['default_payment_method_id']
      PaymentMethod.fetch({ id: @attributes['default_payment_method_id'], customer_id: self.id }, options)
    end
  end
end
