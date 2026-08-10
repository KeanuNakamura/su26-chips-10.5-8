# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  address    :string
#  name       :string
#  ocdid      :string
#  party      :string
#  phone      :string
#  photo_url  :string
#  title      :string
#  twitter    :string
#  website    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

# This file is a stub.
# You should add your own test cases.
# We recommend creating a file for each model in the database.

RSpec.describe Representative do
  describe '.find_rep' do
    let(:official) do
      {
        'name' => 'Jane Doe',
        'type' => 'representative',
        'bio' => { 'party' => 'Democrat' },
        'contact' => {
          'address' => '123 Test, California 2932',
          'phone' => '123-456-7891',
          'url' => 'https://lol.blah.gov'
        },
        'social' => { 'twitter' => 'meow' },
        'references' => {
          'govtrack_id' => '412345',
          'bioguide_id' => 'B00039'
        }
      }
    end

    let(:args) do
      {
        ocdid: '412345',
        title: 'representative'
      }
    end

    before do
      described_class.find_rep(official, **args)
    end

    it 'does not create a duplicate representative' do
      expect do
        described_class.find_rep(official, **args)
      end.not_to change(described_class, :count)
    end

    it 'stores representative information from Geocodio' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      rep = described_class.find_by(ocdid: '412345')
      expect(rep.name).to eq('Jane Doe')
      expect(rep.title).to eq('representative')
      expect(rep.party).to eq('Democrat')
      expect(rep.address).to eq('123 Test, California 2932')
      expect(rep.phone).to eq('123-456-7891')
      expect(rep.website).to eq('https://lol.blah.gov')
      expect(rep.twitter).to eq('meow')
      expect(rep.photo_url).to include('B00039')
    end

    it 'handles missing optional fields' do # rubocop:disable RSpec/ExampleLength
      official = {
        'name' => 'Jane Doe',
        'type' => 'representative',
        'references' => {
          'govtrack_id' => '412345'
        }
      }

      expect do
        described_class.find_rep(
          official,
          ocdid: '412345',
          title: 'representative'
        )
      end.not_to raise_error

      rep = described_class.find_by(ocdid: '412345')
      expect(rep.party).to be_nil
      expect(rep.phone).to be_nil
      expect(rep.photo_url).to be_nil
    end
  end

  describe '.civic_api_to_representative_params' do
    let(:data) do
      JSON.parse(Rails.root.join('spec/fixtures/geocodio_response.json').read)
    end

    it 'builds representatives from a Geocodio response' do
      reps = described_class.civic_api_to_representative_params(data)
      expect(reps).not_to be_empty
      expect(reps.first.name).to be_present
    end
  end
end
