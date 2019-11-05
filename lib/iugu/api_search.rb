module Iugu
  module APICreate
    module ClassMethods
      def search(params = {}, options = {})
        Iugu::Factory.create_from_response self.object_type, APIRequest.request("GET", self.url(params), params, options)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
