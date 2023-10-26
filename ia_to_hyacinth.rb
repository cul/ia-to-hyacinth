# frozen_string_literal: true

require './lib/csv_conversion'

# internet_archive_file = 'spec/fixtures/MuslimWorldManuscripts.csv'
# output_file = '../MuslimWorldManuscripts_hy.csv'

internet_archive_file = 'spec/fixtures/Short.csv'
output_file = '../Short_hy.csv'
CsvConverter.new.convert_csv internet_archive_file, output_file
