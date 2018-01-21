require 'rspec/core'
require 'rspec_api_blueprint/base'
require 'rspec_api_blueprint/configuration'
require 'rspec_api_blueprint/version'
require 'rspec_api_blueprint/string_extensions'
require 'rspec_api_blueprint/spec_helpers'

def doc_file_path(file_name)
  File.join RspecApiBlueprint.configuration.docs_folder, "#{file_name}.md"
end

def documentation_for(example, request, response)
  "## #{example.metadata[:full_description] || action}\n\n".tap do |doc_string|
    doc_string << request_doc(request)
    doc_string << response_doc(response)
  end
end

def request_doc(request)
  request_body = request.body.read
  authorization_header = (request.env && request.env['Authorization']) || request.headers['Authorization']

  if request_body.present? || authorization_header.present?
    "+ Request #{request.content_type}\n\n".tap do |request_doc_string|

      # Request Headers
      if authorization_header.present?
        request_doc_string << "+ Headers\n\n".indent(4)
        request_doc_string << "Authorization: #{authorization_header}\n\n".indent(12)
      end

      # Request Body
      if request_body.present? && request.content_type == 'application/json'
        request_doc_string << "+ Body\n\n".indent(4) if authorization_header
        request_doc_string << "#{JSON.pretty_generate(JSON.parse(request_body))}\n\n".indent(authorization_header.present? ? 12 : 8)
      end
    end
  else
    ''
  end
end

def response_doc(response)
  "+ Response #{response.status} #{response.content_type}\n\n".tap do |response_doc_string|

    # Response Headers
    if response.headers.any?
      response_doc_string << "+ Headers\n\n".indent(4)
      response_doc_string << response.headers.map { |name, value| "#{name}: #{value}\n".indent(12) }.join
      response_doc_string << "\n"
    end

    if response.body.present? && response.content_type == 'application/json'
      response_doc_string << "+ Body\n\n".indent(4)
      response_doc_string << "#{JSON.pretty_generate(JSON.parse(response.body))}\n\n".indent(response.headers.any? ? 12 : 8)
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    $rspec_api_blueprinted_spec_documents ||= {}
  end

  config.after(:each, type: :request) do |example|
    response ||= last_response
    request ||= last_request

    if response
      example_group = example.metadata[:example_group]
      example_groups = []

      while example_group
        example_groups << example_group
        example_group = example_group[:parent_example_group]
      end

      action = example_groups[-2][:description_args].first if example_groups[-2]
      example_groups[-1][:description_args].first.match(/(\w+)\sRequests/)
      path = example.metadata[:example_group][:file_path]
      file_name = path.sub(/^\.\/spec\/(api|integration|request)\//, '').underscore

      # Resource & Action
      spec_doc = documentation_for(example, request, response)

      $rspec_api_blueprinted_spec_documents[file_name] ||= {}
      $rspec_api_blueprinted_spec_documents[file_name][example.metadata[RspecApiBlueprint.configuration.sort_key]] = spec_doc
    end
  end

  config.after(:suite) do
    unless $rspec_api_blueprinted_spec_documents.empty?
      Dir.mkdir(RspecApiBlueprint.configuration.docs_folder) unless Dir.exists?(RspecApiBlueprint.configuration.docs_folder)

      $rspec_api_blueprinted_spec_documents.each do |file_name, spec_docs_by_sort_key|
        file_name_with_path = doc_file_path(file_name)
        directory_name      = File.dirname(file_name_with_path)
        FileUtils.mkdir_p(directory_name) unless File.directory?(directory_name)

        File.open(doc_file_path(file_name), 'w+') do |f|
          ordered_keys = spec_docs_by_sort_key.keys.sort
          ordered_keys.each { |key| f.write spec_docs_by_sort_key[key] }
        end
      end
    end
  end
end
