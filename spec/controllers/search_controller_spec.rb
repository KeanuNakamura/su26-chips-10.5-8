# frozen_string_literal: true

require 'rails_helper'

describe SearchController do
  let(:fixture) { Rails.root.join('spec/fixtures/geocodio_response.json').read }

  before do
    ENV['GEOCODIO_API_KEY'] = 'test-key'
    stub_request(:post, /api\.geocod\.io/).to_return(
      status:  200,
      body:    fixture,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  describe 'GET search' do
    it 'returns a successful response' do
      get :search, params: { address: 'Berkeley, CA' }
      expect(response).to be_successful
    end

    it 'assigns representatives' do
      get :search, params: { address: 'Berkeley, CA' }
      expect(assigns(:representatives)).not_to be_empty
      expect(assigns(:search_term)).to eq('Berkeley, CA')
    end

    it 'renders the search template' do
      get :search, params: { address: 'Berkeley, CA' }
      expect(response).to render_template('representatives/search')
    end
  end
end
