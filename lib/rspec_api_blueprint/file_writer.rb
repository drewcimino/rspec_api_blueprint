module RspecApiBlueprint
  class FileWriter
    def add(example, document)
      file_name = spec_file_name(example)

      @documentation_store[file_name] ||= {}
      @documentation_store[file_name][example.metadata[RspecApiBlueprint.configuration.sort_key]] = document
    end

    def write_to_disk
      unless @documentation_store.empty?
        @documentation_store.each do |file_name, spec_docs_by_sort_key|
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

    private

    def doc_file_path(file_name)
      File.join RspecApiBlueprint.configuration.docs_folder, "#{file_name}.md"
    end


    def spec_file_name(example)
      example_group = example.metadata[:example_group]
      example_groups = []

      while example_group
        example_groups << example_group
        example_group = example_group[:parent_example_group]
      end

      action = example_groups[-2][:description_args].first if example_groups[-2]
      example_groups[-1][:description_args].first.match(/(\w+)\sRequests/) # TODO does this do anything? -DC
      path = example.metadata[:example_group][:file_path]

      path.sub(/^\.\/spec\/(api|integration|request)\//, '').underscore
    end

    def initialize
      @documentation_store = {}
    end
  end
end
