# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrentsClient do
  let(:fixture) { Rails.root.join('spec/fixtures/currents_search.json').read }

  before do
    stub_request(:get, /api\.currentsapi\.services/).to_return(
      status:  200,
      body:    fixture,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  it 'errors without an api key' do
    expect { described_class.new(nil) }.to raise_error(ArgumentError)
  end

  it 'returns the top 5 titles, urls, and descriptions' do
    articles = described_class.new('test-key').search_by_issue('Immigration')

    expect(articles.size).to eq(5)
    expect(articles.first).to eq(
      title:       'Immigration Reform Update',
      description: 'Congress debates a new immigration bill.',
      url:         'https://example.com/immigration-1'
    )
  end

  it 'requests /v1/search with the issue as keywords' do
    described_class.new('test-key').search_by_issue('Free Speech')

    expect(WebMock).to have_requested(:get, 'https://api.currentsapi.services/v1/search')
      .with(query: hash_including('keywords' => 'Free Speech', 'language' => 'en',
                                  'apiKey' => 'test-key'))
  end
end