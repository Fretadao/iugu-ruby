module Iugu
  class ApiToken < APIResource
    def self.retrieve_subaccounts_api_token(options = {})
      APIRequest.request("GET", Iugu.base_uri + "retrieve_subaccounts_api_token", {}, options)
    end

    def self.retrieve_subaccount_api_token(account_id, options = {})
      self.retrieve_subaccounts_api_token(options)['accounts'][account_id]
    end
  end
end
