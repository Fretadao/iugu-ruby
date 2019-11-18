module Iugu
  class Factory
    def self.create_from_response(object_type, response, errors = nil, options = {})
      if response.nil?
        obj = Iugu.const_get(Iugu::Utils.camelize(object_type)).new
        obj.errors = errors if errors
        obj.options = options

        obj
      elsif response.is_a?(Array)
        results = []
        response.each { |i| results.push(Iugu.const_get(Iugu::Utils.camelize(object_type)).new(i, options)) }
        Iugu::SearchResult.new(results, results.count)
      elsif response['items'] && response['totalItems']
        results = []
        response['items'].each { |v| results.push(self.create_from_response(object_type, v, errors, options)) }
        Iugu::SearchResult.new(results, response['totalItems'])
      else
        Iugu.const_get(Iugu::Utils.camelize(object_type)).new(response, options)
      end
    end
  end
end
