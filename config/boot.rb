# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# bin/dev starts Foreman with --env /dev/null, so .env is not loaded otherwise.
env_file = File.expand_path('../.env', __dir__)
if File.exist?(env_file)
  File.foreach(env_file) do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')

    key, value = line.split('=', 2)
    ENV[key] ||= value if key && !key.empty? && value && !value.empty?
  end
end

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

