# frozen_string_literal: true

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

  describe 'POST create' do
    let(:create_params) do
      {
        representative_id: representative.id,
        issue:             'Immigration',
        article_url:       'https://example.com/immigration-2',
        articles:          {
          '0' => {
            title:       'Immigration Reform Update',
            description: 'Congress debates a new immigration bill.',
            url:         'https://example.com/immigration-1'
          },
          '1' => {
            title:       'Border Policy Hearing',
            description: 'Senate holds a hearing on border policy.',
            url:         'https://example.com/immigration-2'
          }
        }
      }
    end

    it 'saves the selected article for the representative' do
      expect { post :create, params: create_params }.to change(NewsItem, :count).by(1)

      item = NewsItem.last
      expect(item.title).to eq('Border Policy Hearing')
      expect(item.link).to eq('https://example.com/immigration-2')
      expect(item.description).to eq('Senate holds a hearing on border policy.')
      expect(item.issue).to eq('Immigration')
      expect(item.representative).to eq(representative)
    end

    it 'redirects to the news item page' do
      post :create, params: create_params
      expect(response).to redirect_to(
        representative_news_item_path(representative, NewsItem.last)
      )
    end

    it 'does not save when no article is selected' do
      expect do
        post :create, params: create_params.merge(article_url: '')
      end.not_to change(NewsItem, :count)
    end
  end
end
