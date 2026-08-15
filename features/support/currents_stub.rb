require 'webmock/cucumber'

ENV['CURRENTS_API_KEY'] ||= 'test-key-not-used'

CURRENTS_FIXTURE = Rails.root.join('spec/fixtures/currents_search.json')

Before do
  stub_request(:get, /api\.currentsapi\.services/).to_return(
    status:  200,
    body:    CURRENTS_FIXTURE.read,
    headers: { 'Content-Type' => 'application/json' }
  )
end