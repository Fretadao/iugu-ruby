module Iugu
  module APIDelete
    def delete(options = {})
      options = self.options.merge(options)
      APIRequest.request("DELETE", self.class.url(self.attributes), {}, options)
      self.errors = nil
      true
    rescue Iugu::RequestWithErrors => ex
      self.errors = ex.errors
      false
    end
  end
end
