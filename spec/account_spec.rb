require 'spec_helper'

describe Iugu::Account do
  let(:account_id) { 1 }
  let(:user_token) { 999 }
  let(:api_tokens) { { "accounts" => { account_id => { "user_token" => user_token } } } }
  let(:factory) { double }
  let(:api_request) { double }
  let(:api_key) { { api_key: 123 } }

  describe '.fetch_accounts' do
    subject { described_class.fetch_accounts(api_key) }

    it 'fetches all accounts for a master account' do
      expect(Iugu::APIRequest).to receive(:request).with("GET", (Iugu.base_uri + "marketplace"), {}, api_key) { api_request }
      expect(Iugu::Factory).to receive(:create_from_response).with("account", api_request, nil, api_key)

      subject
    end
  end

  describe '.create' do
    let(:attributes) { { name: 'Test' } }

    subject { described_class.create(attributes, api_key) }

    context 'successful' do
      it 'creates a new account' do
        expect(Iugu::APIRequest).to receive(:request).with("POST", (Iugu.base_uri + "marketplace" + "/create_account"), attributes, api_key) { api_request }
        expect(Iugu::Factory).to receive(:create_from_response).with("account", api_request, nil, api_key) { factory }

        expect(subject).to eq(factory)
      end
    end

    context 'failure' do
      it 'returns errors' do
        expect(Iugu::APIRequest).to receive(:request).and_raise(Iugu::RequestWithErrors.new(errors: "invalid name"))

        expect(subject.errors).to eq(errors: "invalid name")
      end
    end
  end

  describe '#save' do
    subject { described_class.new(attributes) }

    context 'new account' do
      let(:attributes) { { 'name' => 'Test' } }

      before do
        allow(factory).to receive(:attributes) { attributes.merge(id: account_id) }
      end

      it 'creates a new account' do
        expect(Iugu::APIRequest).to receive(:request).with("POST", (Iugu.base_uri + "marketplace" + "/create_account"), attributes, api_key) { api_request }
        expect(Iugu::Factory).to receive(:create_from_response).with("account", api_request, nil, api_key) { factory }

        expect(subject.save(api_key)).to be_truthy
        expect(subject.id).to eq account_id
        expect(subject.name).to eq 'Test'
      end
    end

    context 'existing account' do
      let(:attributes) { { id: account_id, name: 'Test' } }

      before do
        subject.name = 'Test 123'
        allow(factory).to receive(:attributes) { attributes.merge(name: 'Test 123') }
      end

      it 'creates a new account' do
        expect(Iugu::APIRequest).to receive(:request).with("GET", (Iugu.base_uri + "retrieve_subaccounts_api_token"), {}, api_key) { api_tokens }

        expect(Iugu::APIRequest).to receive(:request).with("PUT", subject.class.url(subject.attributes), { "name" => 'Test 123' }, { api_key: user_token }) { api_request }
        expect(Iugu::Factory).to receive(:create_from_response).with("account", api_request) { factory }

        expect(subject.save(api_key)).to be_truthy
        expect(subject.id).to eq account_id
        expect(subject.name).to eq 'Test 123'
      end
    end
  end

  describe '#refresh' do
    let(:attributes) { { id: 1, name: 'Test', informations: [] } }

    subject { described_class.new(attributes, api_key) }

    before do
      allow(factory).to receive(:attributes) { attributes }
    end

    it 'fetches account data' do
      expect(Iugu::APIRequest).to receive(:request).with("GET", (Iugu.base_uri + "retrieve_subaccounts_api_token"), {}, api_key) { api_tokens }
      expect(Iugu::APIRequest).to receive(:request).with("GET", subject.class.url(subject.id), {}, { api_key: user_token, "user_token" => user_token }) { api_request }
      expect(Iugu::Factory).to receive(:create_from_response).with("account", api_request) { factory }

      expect(subject.refresh).to be_truthy
    end
  end

  describe '#request_verification' do
    let(:attributes) {
      {
        price_range: Iugu::Account::PRICE_RANGE_100_500,
        physical_products: true,
        business_type: 'Finance',
        person_type: Iugu::Account::PERSON_TYPE_COMPANY,
        automatic_transfer: false,
        cnpj: '70.906.882/0001-34',
        company_name: 'Iugu',
        address: 'Av. Paulista, 123',
        cep: '01310-200',
        city: 'São Paulo',
        state: 'SP',
        telephone: '11999999999',
        account_type: Iugu::Account::ACCOUNT_TYPE_CHECKING,
        bank: 'Nubank',
        bank_ag: '0001',
        bank_cc: '00000001',
      }
    }

    subject { described_class.new({ id: 1, name: 'Test' }.merge(attributes), api_key) }

    before do
      allow(factory).to receive(:attributes) { attributes.merge({ informations: []}) }
    end

    it 'verifies account' do
      expect(Iugu::APIRequest).to receive(:request).with("GET", (Iugu.base_uri + "retrieve_subaccounts_api_token"), {}, api_key) { api_tokens }
      expect(Iugu::APIRequest).to receive(:request).with("POST", (subject.class.url(subject.id) + "/request_verification"), { data: attributes.merge(cnpj: "70906882000134") }, { api_key: user_token })

      expect(Iugu::APIRequest).to receive(:request).with("GET", subject.class.url(subject.id), {}, { api_key: user_token, "user_token" => user_token }) { api_request }
      expect(Iugu::Factory).to receive(:create_from_response).with("account", api_request) { factory }

      expect(subject.request_verification).to be_truthy
    end
  end
end
