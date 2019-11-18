module Iugu
  class APIChildResource
    def initialize(parent_keys = {}, fabricator = nil, options = {})
      @parent_keys = parent_keys
      @fabricator = fabricator
      @options = options
    end

    def create(params = {})
      @fabricator.send "create", merge_params(params), options
    end

    def search(params = {})
      @fabricator.send "search", merge_params(params), options
    end

    def fetch(params = nil)
      @fabricator.send "fetch", merge_params({ id: params }), options
    end

    private

    def merge_params(attributes)
      @parent_keys.merge attributes
    end
  end
end
