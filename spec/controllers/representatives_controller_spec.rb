# frozen_string_literal: true

require 'rails_helper'

describe RepresentativesController do
  let!(:representative) do
    Representative.create!(
      name: 'Satwik panigrahi',
      ocdid: '123456',
      title: 'representative',
      party: 'Democrat',
      website: 'https://example.gov'
    )
  end

  describe 'GET index' do
    it 'returns a good response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns the representatives' do
      get :index
      expect(assigns(:representatives)).to include(representative)
    end
  end

  describe 'GET show' do
    it 'returns a good response' do
      get :show, params: { id: representative.id }
      expect(response).to be_successful
    end

    it 'assigns the representative' do
      get :show, params: { id: representative.id }
      expect(assigns(:representative)).to eq(representative)
    end

    it 'renders the show template' do
      get :show, params: { id: representative.id }
      expect(response).to render_template(:show)
    end
  end
end
