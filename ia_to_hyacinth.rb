# frozen_string_literal: true

require 'marc'
require 'csv'
require 'open-uri'

INTERNET_ARCHIVE_IDENTIFIER_PREFIX = 'ldpd_'
INTERNET_ARCHIVE_IDENTIFIER_SUFFIX = '_\d\d\d'

MARC_FILE_URL_PREFIX = 'https://clio.columbia.edu/catalog/'
MARC_FILE_URL_SUFFIX = '.marc'

# Takes as input the path to a CSV of IA entries and returns list containing just the IDs
# IA entries MUST contain a field titled `language`
def get_internet_archive_ids(internet_archive_file)
  clio_ids = []
  CSV.foreach(internet_archive_file, headers: true) do |entry|
    raise "csv files MUST contain a field titled 'identifier' formatted 'ldpd_########_000'" unless entry['identifier']

    # Match a regex for [PREFIX].*?[SUFFIX] and store it in a new array.
    clio_id = entry['identifier'].to_s[
      /#{INTERNET_ARCHIVE_IDENTIFIER_PREFIX}(.*?)#{INTERNET_ARCHIVE_IDENTIFIER_SUFFIX}/m, 1
    ]
    raise "csv files MUST contain a field titled 'identifier' formatted 'ldpd_########_000'" unless entry['identifier']

    clio_ids << clio_id
  end
  clio_ids
end

# Takes in the ID of an Internet Archive entry and returns a has containing:
# primary_clio_id
# primary_record_title
# print_record_clio_id
# print_record_title
def clio_record_from_id(clio_id)
  io_stream = URI.parse("#{MARC_FILE_URL_PREFIX}#{clio_id}#{MARC_FILE_URL_SUFFIX}").open
  reader = MARC::Reader.new(io_stream)
  reader.each do |record|
    puts record
  end
  {}
end

# Path to CSV containing Internet Archive records
internet_archive_file = 'test/MuslimWorldManuscripts.csv'
clio_ids = get_internet_archive_ids(internet_archive_file)
puts clio_ids

clio_records = []
clio_ids.each do |clio_id|
  if clio_id
    clio_record = clio_record_from_id(clio_id)
    clio_records << clio_record
  end
end
# puts clio_records
