# frozen_string_literal: true

# == Schema Information
#
# Table name: counties
#
#  id         :integer          not null, primary key
#  fips_class :string(2)        not null
#  fips_code  :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :integer          not null
#
# Indexes
#
#  index_counties_on_state_id  (state_id)
#
require 'rails_helper'

RSpec.describe County do
  let(:state) do
    State.create!(
      name: 'California', symbol: 'CA', fips_code: 6,
      is_territory: 0, lat_min: 32.30, lat_max: 42.00,
      long_min: 114.08, long_max: 124.24
    )
  end

  it 'correctly codes the fips code' do
    county = state.counties.create!(name: 'Alameda', fips_code: 1, fips_class: 'CA')
    expect(county.std_fips_code).to eq('001')
  end
end
