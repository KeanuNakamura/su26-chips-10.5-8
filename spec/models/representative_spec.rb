# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  city       :string
#  name       :string
#  ocdid      :string
#  party      :string
#  photo_url  :string
#  state      :string
#  street     :string
#  title      :string
#  zip        :string
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
        'party' => 'Democrat',
        'photo_url' => 'https://example.com/a.png'
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
  end
end
