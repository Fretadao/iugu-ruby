require 'spec_helper'

describe Iugu::WithdrawRequest do
  let(:options) { { api_key: '123' } }
  let(:factory) { double }
  let(:api_request) { double }

  describe '.fetch' do
    let(:params) { {} }
    subject { described_class.fetch(params, options) }

    it 'fetches transfers' do
      expect(Iugu::APIRequest).to receive(:request).with("GET", Iugu::WithdrawRequest.url, {}, options) { api_request }
      expect(Iugu::Factory).to receive(:create_from_response).with("withdraw_request", api_request, nil, options) { factory }

      subject
    end
  end

  describe '#refresh' do
    subject { described_class.new({id: "123"}, options).refresh }

    before do
      allow(factory).to receive(:attributes) { { id: 123 } }
    end

    it 'refreshes the transfer data' do
      expect(Iugu::APIRequest).to receive(:request).with("GET", Iugu::WithdrawRequest.url(123), {}, options) { api_request }
      expect(Iugu::Factory).to receive(:create_from_response).with("withdraw_request", api_request) { factory }

      subject
    end
  end
end
