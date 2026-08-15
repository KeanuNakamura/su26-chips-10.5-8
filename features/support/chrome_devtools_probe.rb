# frozen_string_literal: true

# ChromeDriver sometimes probes GET /json/version against the Capybara app
# server. That RoutingError is re-raised on the next visit when
# Capybara.raise_server_errors is true.
class ChromeDevtoolsProbe
  def initialize(app)
    @app = app
  end

  def call(env)
    return [200, { 'Content-Type' => 'application/json' }, ['{}']] if env['PATH_INFO'] == '/json/version'

    @app.call(env)
  end
end

Capybara.app = ChromeDevtoolsProbe.new(Capybara.app)
