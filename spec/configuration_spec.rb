require 'spec_helper'
require 'rspec_api_blueprint'

describe RspecApiBlueprint::Configuration do
  let(:config) { subject }

  describe '#sort_key' do
    it 'uses :location as a default' do
      expect(config.sort_key).to eq(:location)
    end
  end

  describe '#sort_key=' do
    before(:each) { config.sort_key = option}

    context 'with an allowable value' do
      let(:option) { :line_number }

      it 'sets the option value' do
        expect(config.sort_key).to eq(:line_number)
      end
    end

    context 'with an allowable string value' do
      let(:option) { 'line_number' }

      it 'sets the option value as a symbol' do
        expect(config.sort_key).to eq(:line_number)
      end
    end

    context 'with a disallowed value' do
      let(:option) { :garbage }

      it 'does not set the option value' do
        expect(config.sort_key).to eq(:location)
      end
    end
  end

  describe '#docs_folder' do
    it 'uses an "api_docs" folder in the root directory as a default' do
      expect(config.docs_folder).to eq(File.join(File.expand_path('.'), 'api_docs'))
    end
  end

  describe '#docs_folder=' do
    before(:each) { config.docs_folder = path }

    context 'with a simple folder name' do
      let(:path) { 'my_docs'}

      it 'uses the folder name' do
        expect(config.docs_folder).to eq(File.join(File.expand_path('.'), path))
      end
    end

    context 'with a relative path' do
      let(:path) { 'my/nested_docs'}

      it 'uses the folder name' do
        expect(config.docs_folder).to eq(File.join(File.expand_path('.'), path))
      end
    end

    context 'with an absolute path' do
      let(:path) { '/my/nested_docs/elsewhere' }

      it 'uses the absolute path' do
        expect(config.docs_folder).to eq('/my/nested_docs/elsewhere')
      end
    end
  end

  describe '#enabled' do
    it 'is true by default' do
      expect(config.enabled).to eq(true)
    end
  end

  describe '#enabled=' do
    before(:each) { config.enabled = value }

    context 'true' do
      let(:value) { true }

      it 'sets enabled to true' do
        expect(config.enabled).to eq(true)
      end
    end

    context 'false' do
      let(:value) { false }

      it 'sets enabled to false' do
        expect(config.enabled).to eq(false)
      end
    end

    context 'any string' do
      let(:value) { 'false' }

      it 'sets enabled to true' do
        expect(config.enabled).to eq(true)
      end
    end

    context 'nil' do
      let(:value) { nil }

      it 'sets enabled to true' do
        expect(config.enabled).to eq(false)
      end
    end
  end

  describe '#request_headers' do
    it 'is :none by default' do
      expect(config.request_headers).to eq(:none)
    end
  end

  describe '#request_headers=' do
    before(:each) { config.request_headers = value }

    context 'with :all' do
      let(:value) { :all }

      it 'sets the option to :all' do
        expect(config.request_headers).to eq(:all)
      end
    end

    context 'with invalid options :some' do
      let(:value) { :some }

      it 'leaves the option set to :none' do
        expect(config.request_headers).to eq(:none)
      end
    end

    context 'with an only: list' do
      let(:value) { { only: ['Content-Length'] } }

      it 'sets the option to the only: list' do
        expect(config.request_headers).to eq({ only: ['Content-Length'] })
      end
    end

    context 'with an except: list' do
      let(:value) { { except: ['Content-Length'] } }

      it 'sets the option to the except: list' do
        expect(config.request_headers).to eq({ except: ['Content-Length'] })
      end
    end
  end

  describe '#response_headers' do
    it 'is :none by default' do
      expect(config.response_headers).to eq(:none)
    end
  end

  describe '#response_headers=' do
    before(:each) { config.response_headers = value }

    context 'with :all' do
      let(:value) { :all }

      it 'sets the option to :all' do
        expect(config.response_headers).to eq(:all)
      end
    end

    context 'with invalid options :some' do
      let(:value) { :some }

      it 'leaves the the option set to :none' do
        expect(config.response_headers).to eq(:none)
      end
    end

    context 'with an only: list' do
      let(:value) { { only: ['Content-Length'] } }

      it 'sets the option to the only: list' do
        expect(config.response_headers).to eq({ only: ['Content-Length'] })
      end
    end

    context 'with an except: list' do
      let(:value) { { except: ['Content-Length'] } }

      it 'lsets the option to the except: list' do
        expect(config.response_headers).to eq({ except: ['Content-Length'] })
      end
    end
  end
end
