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

# Takes in the ID of an Internet Archive entry and returns its corresponding marc record object.
def get_marc_record(clio_id)
  marc = nil
  until marc
    begin
      marc = URI.parse("#{MARC_FILE_URL_PREFIX}#{clio_id}#{MARC_FILE_URL_SUFFIX}").read
    rescue OpenURI::HTTPError => e
      return nil if e.message.downcase.include? '404 not found'
      puts "#{e.message} (#{MARC_FILE_URL_PREFIX}#{clio_id}#{MARC_FILE_URL_SUFFIX})"
    end
    sleep 0.5
  end
  MARC::Reader.decode(marc)
end

# Takes in a MARC::Record object and returns [print_record_clio_id, print_record_title] or [nil, nil]
def get_print_records record
  [nil, nil]
end

# Takes in the ID of an Internet Archive entry and returns a hash containing:
# primary_clio_id
# primary_record_title
# print_record_clio_id
# print_record_title
def clio_record_from_id(clio_id)
  puts "getting record for #{clio_id}"
  record = get_marc_record(clio_id)
  return nil unless record # Return if record lookup resulted in a 404.

  primary_clio_id = (record.fields '001')[0]
  # Extract the 245 $a subfield and strip off brackets.
  primary_record_title = (record.fields '245')[0]['a'][/\[*(.*?)\]*\.*$/m, 1]
  puts primary_record_title
  print_record_clio_id, print_record_title = get_print_records record

  {primary_clio_id: primary_clio_id, primary_record_title: primary_record_title, print_record_clio_id: print_record_title, print_record_title: primary_record_title}
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
puts clio_records
