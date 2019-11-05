module Iugu
  class Invoice < APIResource
    include Iugu::APIFetch
    include Iugu::APICreate
    include Iugu::APISave
    include Iugu::APIDelete

    def customer
      return false unless @attributes['customer_id']
      Customer.fetch(@attributes['customer_id'], options)
    end

    def cancel
      copy Iugu::Factory.create_from_response(self.class.object_type, APIRequest.request("PUT", "#{self.class.url(self.id)}/cancel", {}, options), nil, options)
      self.errors = nil
      true
    rescue Iugu::RequestWithErrors => ex
      self.errors = ex.errors
      false
    end

    def refund
      copy Iugu::Factory.create_from_response(self.class.object_type, APIRequest.request("POST", "#{self.class.url(self.id)}/refund", {}, options), nil, options)
      self.errors = nil
      true
    rescue Iugu::RequestWithErrors => ex
      self.errors = ex.errors
      false
    end

    def duplicate(params = {})
      params.merge!(id: self.id)

      copy Iugu::Factory.create_from_response(self.class.object_type, APIRequest.request("POST", "#{self.class.url(self.id)}/duplicate", params, options), nil, options)
      self.errors = nil
      true
    rescue Iugu::RequestWithErrors => ex
      self.errors = ex.errors
      false
    end
  end
end
