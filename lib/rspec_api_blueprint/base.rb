module RspecApiBlueprint
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.enable
    if file_writer && file_writer.cached_docs?
      warn 'Warning: Existing cached documentation has been erased by an additional call of RspecApiBlueprint.enable'
    end

    @file_writer = FileWriter.new
  end

  def self.record(example, request, response)
    file_writer.add example, Generator.new(example, request, response).documentation
  end

  def self.write_recorded_docs
    file_writer.write_to_disk
  end

  def self.file_writer
    @file_writer ||= FileWriter.new
  end
end
