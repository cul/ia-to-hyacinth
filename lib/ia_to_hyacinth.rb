require_relative './ia_to_hyacinth/csv_converter'
require_relative './ia_to_hyacinth/exceptions'

module IaToHyacinth
  def self.init_logger(path, level)
    @logger = Logger.new(path)
    @logger.level = level
  end

  def self.logger
    # Default to stdout if logger was not previously initialized with an
    # output file path in the init_logger method.
    @logger ||= Logger.new($stdout)
  end
end
