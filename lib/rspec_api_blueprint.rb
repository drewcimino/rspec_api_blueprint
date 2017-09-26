require "rspec_api_blueprint/version"
require "rspec_api_blueprint/string_extensions"
require "rspec_api_blueprint/spec_helpers"

def api_docs_folder_path
  (defined? Rails) ? File.join(Rails.root, '/api_docs/') : File.join(File.expand_path('.'), '/api_docs/')
end

def doc_file_path(file_name)
  File.join(api_docs_folder_path, "#{file_name}.md")
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
      spec_doc = "## #{example.metadata[:full_description] || action}\n\n"

      # Request
      request_body = request.body.read
      authorization_header = request.env ? request.env['Authorization'] : request.headers['Authorization']

      if request_body.present? || authorization_header.present?
        spec_doc << "+ Request #{request.content_type}\n\n"

        # Request Headers
        if authorization_header.present?
          spec_doc << "+ Headers\n\n".indent(4)
          spec_doc << "Authorization: #{authorization_header}\n\n".indent(12)
        end

        # Request Body
        if request_body.present? && request.content_type == 'application/json'
          spec_doc << "+ Body\n\n".indent(4) if authorization_header
          spec_doc << "#{JSON.pretty_generate(JSON.parse(request_body))}\n\n".indent(authorization_header ? 12 : 8)
        end
      end

      # Response
      spec_doc << "+ Response #{response.status} #{response.content_type}\n\n"

      if response.body.present? && response.content_type == 'application/json'
        spec_doc << "#{JSON.pretty_generate(JSON.parse(response.body))}\n\n".indent(8)
      end

      $rspec_api_blueprinted_spec_documents[file_name] ||= {}
      $rspec_api_blueprinted_spec_documents[file_name][example.metadata[:line_number]] = spec_doc
    end
  end

  config.after(:suite) do
    unless $rspec_api_blueprinted_spec_documents.empty?
      Dir.mkdir(api_docs_folder_path) unless Dir.exists?(api_docs_folder_path)

      $rspec_api_blueprinted_spec_documents.each do |file_name, spec_docs_by_line_number|
        file_name_with_path = doc_file_path(file_name)
        directory_name      = File.dirname(file_name_with_path)
        FileUtils.mkdir_p(directory_name) unless File.directory?(directory_name)

        File.open(doc_file_path(file_name), 'w+') do |f|
          ordered_line_numbers = spec_docs_by_line_number.keys.sort
          ordered_line_numbers.each { |line_number| f.write spec_docs_by_line_number[line_number] }
        end
      end
    end
  end
end
