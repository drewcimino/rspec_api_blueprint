# Rspec Api Blueprint

Autogeneration of API documentation using the Blueprint format from request specs.

You can find more about Blueprint at http://apiblueprint.org

## What is this?

  This is a heavily refactored fork of calderalabs/rspec_api_blueprint with several added features, mostly related to configuration options giving you more control over the output format.

### RspecApiBlueprint.configuration

  Is a configuration object that you can use to store settings about how you want RspecApiBlueprint to write your documentation. The following configuration options are available via `Configuration#method=`:

  * `#sort_key`: (default: `:location`) The attribute applied to each spec to determine the order it should be printed in the documentation file. This can be useful for git-tracked documentation folders in order to track changes to the API as the requests and response change in your test suite. Available options are: `:location`, `:line_number`.
  * `#docs_folder`: (default: `'./api_docs/'`) The folder in which to write/store output documentation files.
  * `#enabled`: (default: `true`) Record/write requests and responses from Rspec api/integration specs.
  * `#request_headers`: (default: `:none`) Request headers to record and write into the documentation. Available options are `:all`, `:none`, `only: ['header', 'names', 'to', 'record']`, and, `except: ['header', 'names', 'to', 'ignore']`.
  * `#response_headers`: (default: `:none`): Exactly the same as #request_headers, but for the responses.

## Installation & Usage

### Rails

Add this line to your application's Gemfile, probably under `group :test` :

    gem 'rspec_api_blueprint', git: 'https://github.com/drewcimino/rspec_api_blueprint.git'

And then execute:

    $ bundle

### Plain Ruby

Install it yourself:

    $ gem install rspec_api_blueprint

and

    require 'rspec_api_blueprint'

as needed.

## Spec Conventions

Write  using the following convention:

- Tests must be placed in `spec/requests` folder or they have to be tagged with `type: :request`
- Top level descriptions are named after the model (plural form) followed by the word “Requests”. For a example model called Arena it would be “Arenas Requests”.
- Second level descriptions are actions in the form of “VERB path”. For the show action of the Arenas controller it would be “GET /arenas/{id}”.

Example:

    describe 'Arenas Requests' do
      describe 'GET /v1/arenas/{id}' do
        it 'responds with the requested arena' do
          arena = create :arena, foursquare_id: '5104'
          get v1_arena_path(arena)

          response.status.should eq(200)
        end
      end
    end

The output:

    # GET /v1/arenas/{id}

    + Response 200 (application/json)

        {
          "arena": {
            "id": "4e9dbbc2-830b-41a9-b7db-9987735a0b2a",
            "name": "Clinton St. Baking Co. & Restaurant",
            "latitude": 40.721294,
            "longitude": -73.983994,
            "foursquare_id": "5104"
          }
        }

## Caveats

401, 403 and 301 statuses are ignored since rspec produces an undesired output.

TODO: Add option to choose ignored statuses.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
