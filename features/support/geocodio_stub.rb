# frozen_string_literal: true

require 'webmock/cucumber'

WebMock.disable_net_connect!(allow_localhost: true)

ENV['GEOCODIO_API_KEY'] ||= 'test-key-not-used'

GEOCODIO_FIXTURE = Rails.root.join('spec/fixtures/geocodio_response.json')

Before do
  # The geocodio-gem client POSTs. A :get stub will not match, and the request
  # will still try to reach the network.
  stub_request(:post, /api\.geocod\.io/).to_return(
    status: 200,
    body: GEOCODIO_FIXTURE.read,
    headers: { 'Content-Type' => 'application/json' }
  )
end
