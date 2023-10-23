# frozen_string_literal: true

require 'csv'
require 'logger'
require 'marc'
require 'open-uri'
require 'retriable'

INTERNET_ARCHIVE_IDENTIFIER_PREFIX = 'ldpd_'
INTERNET_ARCHIVE_IDENTIFIER_SUFFIX = '_\d\d\d'

MARC_FILE_URL_PREFIX = 'https://clio.columbia.edu/catalog/'
MARC_FILE_URL_SUFFIX = '.marc'

PRINT_RECORD_IDENTIFIER_PREFIX = '(OCoLC)'

LOG_FILE_PATH = 'error.log'

class UserError < StandardError
end

# Takes as input the path to a CSV of IA entries and returns list containing just the IDs
# IA entries MUST contain a field titled `language`
def get_internet_archive_ids(internet_archive_file)
  clio_ids = []
  CSV.foreach(internet_archive_file, headers: true) do |entry|
    raise UserError, "csv files MUST contain a field titled 'identifier' formatted 'ldpd_########_000'" unless entry['identifier']

    # Match a regex for [PREFIX].*?[SUFFIX] and store it in a new array.
    clio_id = entry['identifier'].to_s[
      /#{INTERNET_ARCHIVE_IDENTIFIER_PREFIX}(.*?)#{INTERNET_ARCHIVE_IDENTIFIER_SUFFIX}/m, 1
    ]
    raise UserError, "csv files MUST contain a field titled 'identifier' formatted 'ldpd_########_000'" unless entry['identifier']

    clio_ids << clio_id
  end
  clio_ids
end

# Takes in the ID of an Internet Archive entry and returns its corresponding marc record object.
def get_marc_record(clio_id)
  marc_file_path = "#{MARC_FILE_URL_PREFIX}#{clio_id}#{MARC_FILE_URL_SUFFIX}"

  handle_http_error = proc do |exception|
    puts "#{exception.message} (#{marc_file_path})"
    raise UserError, "File not found: '#{marc_file_path}'" if exception.message.downcase.include? '404 not found'
  end

  Retriable.retriable(on: OpenURI::HTTPError, tries: 10, on_retry: handle_http_error) do
    marc = URI.parse(marc_file_path).read
    MARC::Reader.decode(marc)
  end
end

# Takes in a 776 $w subfield and returns the ID it contains if it exists.
def extract_print_record_id(prev, subfield)
  return prev unless subfield.include? PRINT_RECORD_IDENTIFIER_PREFIX
  raise UserError, "Multiple print records found for #{record.fields('001')[0]}" if prev

  field['w'][/#{PRINT_RECORD_IDENTIFIER_PREFIX}(.*?)$/m, 1]
end

# Takes in a MARC::Record object and returns [print_record_clio_id, print_record_title] or [nil, nil]
def get_print_records record
  print_record_clio_id = nil
  record.each_by_tag '776' do |field|
    next unless field.include? 'w'

    if field['w'].is_a? Array
      field['w'].each { |element| extract_print_record_id(print_record_clio_id, element) }
    else
      extract_print_record_id(print_record_clio_id, field['w'])
    end
  end
  # Get MARC for print_record_clio_id, check that 035 $a matches.
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

  primary_clio_id = record.fields('001')[0]
  # Extract the 245 $a subfield and strip off brackets.
  primary_record_title = record.fields('245')[0]['a'][/\[*(.*?)\]*\.*$/m, 1]
  puts primary_record_title
  print_record_clio_id, print_record_title = get_print_records record

  {primary_clio_id: primary_clio_id, primary_record_title: primary_record_title, 
   print_record_clio_id: print_record_title, print_record_title: primary_record_title}
end

log = Logger.new(LOG_FILE_PATH)
# Path to CSV containing Internet Archive records
internet_archive_file = 'test/MuslimWorldManuscripts.csv'
begin
  clio_ids = get_internet_archive_ids(internet_archive_file)
rescue StandardError => e
  log.error(e.message)
  abort(e.message)
end
puts clio_ids

clio_records = []
clio_ids.each do |clio_id|
  begin
    if clio_id
      clio_record = clio_record_from_id(clio_id)
      clio_records << clio_record if clio_record
    end
    sleep 0.5
  rescue UserError => e
    log.error(e.message)
  rescue StandardError => e
    log.error(e.message)
    log.error(e.backtrace.to_s)
    raise
  end
end
