require 'rspec/core'
require 'rspec_api_blueprint/base'
require 'rspec_api_blueprint/configuration'
require 'rspec_api_blueprint/file_writer'
require 'rspec_api_blueprint/generator'
require 'rspec_api_blueprint/spec_helpers'
require 'rspec_api_blueprint/string_extensions'
require 'rspec_api_blueprint/version'

RSpec.configure do |config|
  config.before(:suite) do
    RspecApiBlueprint.enable
  end

  config.after(:each, type: :request) do |example|
    if response ||= last_response
      request ||= last_request

      RspecApiBlueprint.record example, request, response
    end
  end

  config.after(:suite) do
    RspecApiBlueprint.write_recorded_docs
  end
end
