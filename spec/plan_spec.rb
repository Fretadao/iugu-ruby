require 'spec_helper'

describe Iugu::Plan do
  subject(:client) { Iugu::Client.new }

  describe '.create' do
    it 'should create a plan', :vcr do
      plan = client.plan.create(name: 'Medium',
                               identifier: 'medium',
                               interval: '1',
                               interval_type: 'months',
                               value_cents: '10000') # R$ 100,00

      expect(plan.is_new?).to be_falsy
      expect(plan.name).to eq('Medium')
      expect(plan.identifier).to eq('medium')
      expect(plan.interval).to eq(1)
      expect(plan.interval_type).to eq('months')
      expect(plan.prices.first['value_cents']).to eq(10000)
    end
  end

  describe '.fetch' do
    it 'should return plans', :vcr do
      plan = client.plan.fetch

      expect(plan.total).to eq(2)
    end

    it 'should return the plan', :vcr do
      plan = client.plan.fetch_by_identifier('medium')

      expect(plan.name).to eq('Medium')
      expect(plan.identifier).to eq('medium')
      expect(plan.interval).to eq(1)
      expect(plan.interval_type).to eq('months')
      expect(plan.prices.first['value_cents']).to eq(10000)
    end
  end

  describe '.save' do
    it 'should save the plan', :vcr do
      plan = client.plan.fetch_by_identifier('medium')

      plan.name = 'Super Medium'
      plan.value_cents = '12000'

      plan.save

      saved_plan = client.plan.fetch(id: plan.id)

      expect(saved_plan.name).to eq('Super Medium')
      expect(saved_plan.prices.first['value_cents']).to eq(12000)
    end
  end

  describe '.delete' do
    it 'should delete the plan', :vcr do
      plan = client.plan.fetch_by_identifier('medium')

      plan.delete

      expect { client.plan.fetch(id: plan.id) }.to raise_error(Iugu::ObjectNotFound)
    end
  end
end
