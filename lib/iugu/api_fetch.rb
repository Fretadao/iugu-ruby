module Iugu
  module APIFetch
    def refresh(options = {})
      copy Iugu::Factory.create_from_response(self.class.object_type, APIRequest.request("GET", self.class.url(self.id), {}, options))
      self.errors = nil
      true
    rescue Iugu::RequestWithErrors => ex
      self.errors = ex.errors
      false
    end

    module ClassMethods
      def fetch(params = nil, options = {})
        Iugu::Factory.create_from_response(self.object_type, APIRequest.request("GET", self.url(params), {}, options), nil, options)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
