require 'rspec/core'
require 'rspec_api_blueprint/base'
require 'rspec_api_blueprint/configuration'
require 'rspec_api_blueprint/version'
require 'rspec_api_blueprint/string_extensions'
require 'rspec_api_blueprint/spec_helpers'
require 'rspec_api_blueprint/generator'
require 'rspec_api_blueprint/file_writer'

RSpec.configure do |config|
  config.before(:suite) do
    $file_writer = RspecApiBlueprint::FileWriter.new
  end

  config.after(:each, type: :request) do |example|
    if response ||= last_response
      request ||= last_request
      $file_writer.add example, RspecApiBlueprint::Generator.new(example, request, response).documentation
    end
  end

  config.after(:suite) do
    $file_writer.write_to_disk
  end
end
