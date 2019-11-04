require 'spec_helper'

describe Iugu::Invoice do
  subject(:client) { Iugu::Client.new }

  describe '.create' do
    it 'should create an invoice for credit card payment', :vcr do
      invoice = client.invoice.create(email: 'homer@simpsom.com',
                                     due_date: '2017-11-30',
                                     items: [{ price_cents: 100, description: 'Rosquinha', quantity: 99 }],
                                     payable_with: 'credit_card')

      expect(invoice.is_new?).to be_falsy
      expect(invoice.email).to eq('homer@simpsom.com')
      expect(invoice.due_date).to eq('2017-11-30')
      expect(invoice.status).to eq('pending')
      expect(invoice.total_cents).to eq(9900)
      expect(invoice.payable_with).to eq('credit_card')
    end
  end

  describe '.fetch' do
    it 'should return invoices', :vcr do
      invoices = client.invoice.fetch

      expect(invoices.total).to eq(5)
    end

    it 'should return invoice', :vcr do
      invoice = client.invoice.fetch(id: '3F14349B01264947A3765A79B1DEA1B4')

      expect(invoice.email).to eq('homer@simpsom.com')
      expect(invoice.due_date).to eq('2017-11-30')
      expect(invoice.status).to eq('pending')
      expect(invoice.total_cents).to eq(9900)
      expect(invoice.payable_with).to eq('credit_card')
    end
  end
end
