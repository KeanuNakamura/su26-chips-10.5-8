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
    it 'does not create a duplicate representative' do
      official = {
        'name' => 'Jane Doe',
        'party' => 'Democrat',
        'photo_url' => 'https://example.com/a.png'
      }

      Representative.find_rep(
        official,
        ocdid: '412345',
        title: 'representative'
      )

      expect {
        Representative.find_rep(
          official,
          ocdid: '412345',
          title: 'representative'
        )
      }.not_to change(Representative, :count)
    end
  end
end
