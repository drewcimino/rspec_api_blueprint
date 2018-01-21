module RspecApiBlueprint
  class Configuration
    ALLOWABLE_SORT_KEYS = [
      :line_number,
      :location
    ].freeze

    attr_reader :sort_key
    attr_reader :docs_folder
    attr_reader :enabled

    def sort_key=(key)
      @sort_key = key.to_sym if ALLOWABLE_SORT_KEYS.include? key.to_sym
    end

    def docs_folder=(path)
      @docs_folder = path[0] == '/' ? path : File.join(base_path, "#{path}")
    end

    def enabled=(boolean)
      @enabled = !!boolean
    end

    private

    def initialize
      @enabled     = true
      @sort_key  = :location
      @docs_folder = File.join File.expand_path('.'), 'api_docs'
    end

    def base_path
      (defined? Rails) ? Rails.root : File.expand_path('.')
    end
  end
end
