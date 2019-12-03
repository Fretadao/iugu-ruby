module Iugu
  class Transfer < APIResource
    include Iugu::APIFetch
    include Iugu::APICreate
  end
end
