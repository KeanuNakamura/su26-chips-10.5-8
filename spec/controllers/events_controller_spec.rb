# frozen_string_literal: true

require 'rails_helper'

describe EventsController do
  let(:state) do
    State.create!(
      name: 'California', symbol: 'CA', fips_code: 6,
      is_territory: 0, lat_min: 32.30, lat_max: 40.00,
      long_min: 114.8, long_max: 124.24
    )
  end
  let(:county) { state.counties.create!(name: 'Alameda', fips_code: 1, fips_class: 'CA') }
  let!(:event) do
    Event.create!(
      name: 'Town Hall',
      description: 'Community meeting',
      county: county,
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 2.hours
    )
  end

  describe 'GET index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns all events when no filter is given' do
      get :index
      expect(assigns(:events)).to include(event)
    end

    it 'filters events by state' do
      get :index, params: { 'filter-by' => 'state-only', 'state' => 'CA' }
      expect(assigns(:events)).to include(event)
    end
  end

  describe 'GET show' do
    it 'returns a successful response' do
      get :show, params: { id: event.id }
      expect(response).to be_successful
    end

    it 'assigns the event' do
      get :show, params: { id: event.id }
      expect(assigns(:event)).to eq(event)
    end
  end
end
