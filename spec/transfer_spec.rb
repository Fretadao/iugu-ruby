require 'spec_helper'

describe Iugu::Transfer do
  let(:options) { { api_key: '123' } }
  let(:factory) { double }
  let(:api_request) { double }

  describe '.create' do
    let(:attributes) { { receiver_id: "1", amount_cents: 10000, custom_variables: [{name: 'x', value: 'x'}] } }
    subject { described_class.create(attributes, options) }

    it 'creates a new transfer' do
      expect(Iugu::APIRequest).to receive(:request).with("POST", Iugu::Transfer.url(attributes), attributes, options) { api_request }
      expect(Iugu::Factory).to receive(:create_from_response).with("transfer", api_request, nil, options) { factory }

      subject
    end
  end

  describe '.fetch' do
    let(:params) { {} }
    subject { described_class.fetch(params, options) }

    it 'fetches transfers' do
      expect(Iugu::APIRequest).to receive(:request).with("GET", Iugu::Transfer.url, {}, options) { api_request }
      expect(Iugu::Factory).to receive(:create_from_response).with("transfer", api_request, nil, options) { factory }

      subject
    end
  end

  describe '#refresh' do
    subject { described_class.new({id: "123"}, options).refresh }

    before do
      allow(factory).to receive(:attributes) { { id: 123 } }
    end

    it 'refreshes the transfer data' do
      expect(Iugu::APIRequest).to receive(:request).with("GET", Iugu::Transfer.url(123), {}, options) { api_request }
      expect(Iugu::Factory).to receive(:create_from_response).with("transfer", api_request) { factory }

      subject
    end
  end

  describe '.search' do
    subject { described_class.search({ id: "123" }, options) }

    it 'searches transfers' do
      expect(Iugu::APIRequest).to receive(:request).with("GET", Iugu::Transfer.url({ id: "123" }), { id: "123" }, options) { api_request }
      expect(Iugu::Factory).to receive(:create_from_response).with("transfer", api_request) { factory }

      subject
    end
  end
end
