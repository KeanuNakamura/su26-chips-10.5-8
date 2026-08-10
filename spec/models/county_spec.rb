# frozen_string_literal: true

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
