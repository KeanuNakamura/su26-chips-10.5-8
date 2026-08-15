require 'rails_helper'

describe MyNewsItemsController do
  let(:representative) do
    Representative.create!(
      name:  'Satwik Panigrahi',
      ocdid: '123456',
      title: 'representative'
    )
  end
  let(:user) do
    User.create!(
      uid:        '123456',
      provider:   :github,
      first_name: 'Test',
      last_name:  'User',
      email:      'test@example.com'
    )
  end
  let(:fixture) { Rails.root.join('spec/fixtures/currents_search.json').read }

  before do
    session[:user_id] = user.id
    ENV['CURRENTS_API_KEY'] = 'test-key'
    stub_request(:get, /api\.currentsapi\.services/).to_return(
      status:  200,
      body:    fixture,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  describe 'GET search' do
    it 'returns a successful response' do
      get :search, params: { representative_id: representative.id, issue: 'Immigration' }
      expect(response).to be_successful
    end

    it 'assigns the top 5 articles from CurrentsAPI' do
      get :search, params: { representative_id: representative.id, issue: 'Immigration' }
      expect(assigns(:articles).size).to eq(5)
      expect(assigns(:articles).first[:title]).to eq('Immigration Reform Update')
    end

    it 'renders the search template' do
      get :search, params: { representative_id: representative.id, issue: 'Immigration' }
      expect(response).to render_template('search')
    end
  end
end