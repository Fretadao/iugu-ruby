module Iugu
  module APICreate
    module ClassMethods
      def create(attributes = {}, options = {})
        options = self.options.merge(options)
        Iugu::Factory.create_from_response(self.object_type,  APIRequest.request("POST", self.url(attributes), attributes, options), nil, options)
      rescue Iugu::RequestWithErrors => ex
        obj = self.new
        obj.set_attributes attributes, true
        obj.errors = ex.errors
        obj
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
