module RspecApiBlueprint
  class Generator
    def documentation
      "## #{@example.metadata[:full_description] || action}\n\n".tap do |doc_string|
        doc_string << request_doc
        doc_string << response_doc
      end
    end

    private

    def initialize(example, request, response)
      @example  = example
      @request  = request
      @response = response
    end

    def request_doc
      request_body = @request.body.read
      authorization_header = (@request.env && @request.env['Authorization']) || @request.headers['Authorization']

      if request_body.present? || authorization_header.present?
        "+ Request #{@request.content_type}\n\n".tap do |request_doc_string|

          # Request Headers
          if authorization_header.present?
            request_doc_string << "+ Headers\n\n".indent(4)
            request_doc_string << "Authorization: #{authorization_header}\n\n".indent(12)
          end

          # Request Body
          if request_body.present? && @request.content_type == 'application/json'
            request_doc_string << "+ Body\n\n".indent(4) if authorization_header
            request_doc_string << "#{JSON.pretty_generate(JSON.parse(request_body))}\n\n".indent(authorization_header.present? ? 12 : 8)
          end
        end
      else
        ''
      end
    end

    def response_doc
      "+ Response #{@response.status} #{@response.media_type}\n\n".tap do |response_doc_string|

        # Response Headers
        selected = documentable_response_headers

        if selected.any?
          response_doc_string << "+ Headers\n\n".indent(4)
          response_doc_string << selected.map { |name, value| "#{name}: #{value}\n".indent(12) }.join
          response_doc_string << "\n"
        end

        if @response.body.present? && @response.media_type == 'application/json'
          response_doc_string << "+ Body\n\n".indent(4)
          response_doc_string << "#{JSON.pretty_generate(JSON.parse(@response.body))}\n\n".indent(@response.headers.any? ? 12 : 8)
        end
      end
    end

    def documentable_response_headers
      if RspecApiBlueprint.configuration.response_headers == :all
        @response.headers
      elsif RspecApiBlueprint.configuration.response_headers == :none
        {}
      elsif included = RspecApiBlueprint.configuration.response_headers[:only]
        included = included.map(&:to_s)

        @response.headers.each_with_object({}) do |(field, value), filtered_headers|
          filtered_headers[field] = value if included.include? field
        end
      elsif excluded = RspecApiBlueprint.configuration.response_headers[:except]
        included = @response.headers.keys - excluded.map(&:to_s)

        @response.headers.each_with_object({}) do |(field, value), filtered_headers|
          filtered_headers[field] = value if included.include? field
        end
      end
    end
  end
end
