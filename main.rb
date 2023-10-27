# frozen_string_literal: true

require './lib/ia_to_hyacinth'

LOG_FILE_PATH = 'error.log'
IaToHyacinth.init_logger(LOG_FILE_PATH, Logger::DEBUG)

# internet_archive_file = 'spec/fixtures/MuslimWorldManuscripts.csv'
# output_file = '../MuslimWorldManuscripts_hy.csv'

internet_archive_file = 'spec/fixtures/Short.csv'
output_file = '../Short_hy.csv'
csv_converter = IaToHyacinth::CsvConverter.new
csv_converter.convert_csv internet_archive_file, output_file
