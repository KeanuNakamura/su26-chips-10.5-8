# frozen_string_literal: true

require 'faraday'
require 'json'

class CurrentsClient
  class Error < StandardError; end

  # Trailing slash is required. Faraday treats the last path segment as a file,
  # so 'https://.../v1' + 'search' becomes 'https://.../search'.
  BASE_URL = 'https://api.currentsapi.services/v1/'
  RESULTS_LIMIT = 5

  def initialize(api_key)
    raise ArgumentError, 'API key is missing' if api_key.blank?

    @api_key = api_key
    @conn = Faraday.new(url: BASE_URL) do |faraday|
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def search_by_issue(issue)
    response = @conn.get('search') do |request|
      request.params = {
        keywords: issue,
        language: 'en',
        apiKey:   @api_key
      }
      request.headers['Authorization'] = @api_key
      request.headers['Accept'] = 'application/json'
    end

    raise Error, "API error: #{response.status}" unless response.status == 200

    news = parsed_body(response)['news']
    Array(news).first(RESULTS_LIMIT).map do |article|
      {
        title:       article['title'],
        description: article['description'],
        url:         article['url']
      }
    end
  end

  private

  def parsed_body(response)
    body = response.body
    body = JSON.parse(body) if body.is_a?(String)
    body.is_a?(Hash) ? body : {}
  end
end
