require 'spec_helper'

describe Iugu::APIResource do
  describe 'is_new?' do
    subject(:is_new) { described_class.new(attributes).is_new? }

    context 'when id is set' do
      let(:attributes) { { id: 123 } }

      it { is_expected.to be false }
    end

    context 'when id not is set' do
      let(:attributes) { {} }

      it { is_expected.to be true }
    end
  end

  describe 'assign_attributes?' do
    subject(:assign_attributes) { described_class.new(abc: 123).assign_attributes(attributes) }

    context 'when attributes are empty' do
      let(:attributes) { {} }

      it 'returns instance without assignments' do
        expect(assign_attributes.attributes['abc']).to eq 123
      end
    end

    context 'when attributes are not empty' do
      let(:attributes) { { abc: 321 } }

      it 'returns instance with assignments' do
        expect(assign_attributes.attributes['abc']).to eq 321
      end
    end
  end
end
