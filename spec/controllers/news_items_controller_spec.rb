# frozen_string_literal: true

require 'rails_helper'

describe NewsItemsController do
  let(:representative) do
    Representative.create!(
      name: 'Jane Doe',
      ocdid: '412345',
      title: 'representative'
    )
  end
  let!(:news_item) do
    NewsItem.create!(
      title: 'Local headline',
      link: 'https://example.com/article',
      description: 'Summary text',
      representative: representative
    )
  end

  describe 'GET index' do
    it 'returns a successful response' do
      get :index, params: { representative_id: representative.id }
      expect(response).to be_successful
    end

    it 'assigns the representative news items' do
      get :index, params: { representative_id: representative.id }
      expect(assigns(:news_items)).to include(news_item)
    end
  end

  describe 'GET show' do
    it 'returns a successful response' do
      get :show, params: { representative_id: representative.id, id: news_item.id }
      expect(response).to be_successful
    end

    it 'assigns the news item' do
      get :show, params: { representative_id: representative.id, id: news_item.id }
      expect(assigns(:news_item)).to eq(news_item)
    end
  end
end
