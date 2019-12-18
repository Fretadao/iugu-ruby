require 'cpf_cnpj'

module Iugu
  class Account < APIResource
    include Iugu::APIFetch
    include Iugu::APISave
    include Iugu::APIDelete

    PERSON_TYPE_INDIVIDUAL = 'Pessoa Física'
    PERSON_TYPE_COMPANY = 'Pessoa Jurídica'
    PRICE_RANGE_100 = 'Até R$ 100,00'
    PRICE_RANGE_100_500 = 'Entre R$ 100,00 e R$ 500,00'
    PRICE_RANGE_500 = 'Mais que R$ 500,00'
    ACCOUNT_TYPE_CHECKING = 'Corrente'
    ACCOUNT_TYPE_SAVING = 'Poupança'
    BANKS = ['Itaú', 'Bradesco', 'Caixa Econômica', 'Banco do Brasil', 'Santander', 'Banrisul', 'Sicredi', 'Sicoob',
             'Inter', 'BRB', 'Via Credi', 'Neon', 'Nubank', 'Pagseguro', 'Banco Original']

    def self.fetch_accounts(options = {})
      Iugu::Factory.create_from_response(object_type, APIRequest.request("GET", self.marketplace_url, {}, options), nil, options)
    end

    def self.create(attributes = {}, options = {})
      Iugu::Factory.create_from_response(self.object_type, APIRequest.request("POST", "#{self.marketplace_url}/create_account", attributes, options), nil, options)
    rescue Iugu::RequestWithErrors => ex
      obj = self.new
      obj.set_attributes attributes, true
      obj.errors = ex.errors
      obj
    end

    def self.find(account_id, options = {})
      acc = self.new({ id: account_id }, options)
      acc.refresh
      acc
    end

    def save(options = {})
      self.options = options if self.options.empty?

      if is_new?
        copy(self.class.create(self.attributes, self.options))
      else
        refresh_tokens if self.options['user_token'].nil?
        super(api_key: self.options['user_token'])
      end

      self.errors = nil
      true
    rescue Iugu::RequestWithErrors => ex
      self.errors = ex.errors
      false
    end

    def refresh
      refresh_tokens if self.options['user_token'].nil?
      super(api_key: options['user_token'])

      self.informations.each do |info|
        self.add_accessor(info['key'])
        eval("self.#{info['key']} = '#{info['value']}'")
      end

      true
    end

    def request_verification(params = nil)
      refresh_tokens if self.options['user_token'].nil?
      params ||= build_request_verification
      APIRequest.request("POST", "#{self.class.url(self.id)}/request_verification", params, { api_key: self.options['user_token'] })
      self.errors = nil
      self.refresh
    rescue Iugu::RequestWithErrors => ex
      self.errors = ex.errors
      false
    end

    private

    def build_request_verification
      if self.respond_to?(:cnpj)
        cnpj = CNPJ.new(self.cnpj)
        self.cnpj = cnpj.stripped
      end

      if self.respond_to?(:cpf)
        cpf = CPF.new(self.cpf)
        self.cpf = cpf.stripped
      end

      self.physical_products ||= false

      raise "Invalid price range" if ![PRICE_RANGE_100, PRICE_RANGE_100_500, PRICE_RANGE_500].include?(self.price_range)
      raise "Invalid business type" if self.business_type.nil?
      raise "Invalid person type" if ![PERSON_TYPE_COMPANY, PERSON_TYPE_INDIVIDUAL].include?(self.person_type)
      raise "Invalid automatic transfer" if self.automatic_transfer.nil?

      if self.person_type == PERSON_TYPE_COMPANY
        raise "Invalid CNPJ" if !cnpj.valid?
        raise "Invalid company name" if self.company_name.nil?
      end

      if self.person_type == PERSON_TYPE_INDIVIDUAL
        raise "Invalid CPF" if !cpf.valid?
        raise "Invalid name" if self.company_name.nil?
      end

      raise "Invalid address" if self.address.nil?
      raise "Invalid cep" if self.cep.nil?
      raise "Invalid city" if self.city.nil?
      raise "Invalid state" if self.state.nil?

      raise "Invalid telephone" if self.telephone.nil?

      raise "Invalid account type" if ![ACCOUNT_TYPE_CHECKING, ACCOUNT_TYPE_SAVING].include?(self.account_type)
      raise "Invalid bank" if !BANKS.include?(self.bank)
      raise "Invalid bank ag" if self.bank_ag.nil?
      raise "Invalid bank cc" if self.bank_cc.nil?

      data = {
        data: {
          physical_products: self.physical_products,
          price_range: self.price_range,
          business_type: self.business_type,
          person_type: self.person_type,
          automatic_transfer: self.automatic_transfer,
          company_name: self.company_name,
          address: self.address,
          city: self.city,
          state: self.state,
          cep: self.cep,
          bank: self.bank,
          bank_ag: self.bank_ag,
          bank_cc: self.bank_cc,
          account_type: self.account_type,
          cnpj: self.cnpj,
          telephone: self.telephone,
        }
      }

      return data
    end

    def refresh_tokens
      self.options.merge!(ApiToken.retrieve_subaccount_api_token(self.id, self.options))
    end

    def self.marketplace_url
      Iugu.base_uri + "marketplace"
    end
  end
end
