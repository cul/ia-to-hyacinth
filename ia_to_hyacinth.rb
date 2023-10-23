# frozen_string_literal: true

require 'csv'
require 'json'
require 'logger'
require 'marc'
require 'open-uri'
require 'retriable'

IA_IDENTIFIER_PREFIX = 'ldpd_'
IA_IDENTIFIER_SUFFIX = '_\d\d\d'

MARC_FILE_URL_PREFIX = 'https://clio.columbia.edu/catalog/'
MARC_FILE_URL_SUFFIX = '.marc'

OCLC_JSON_PREFIX = 'https://clio.columbia.edu/catalog.json?q=(OCoLC)ocm'

PRINT_RECORD_IDENTIFIER_PREFIX = '(OCoLC)'

LOG_FILE_PATH = 'error.log'

class UserError < StandardError
end

# Takes in the path to a CSV of IA entries and returns list containing just the IDs
# IA entries MUST contain a field titled `language`
def get_internet_archive_ids(internet_archive_file)
  clio_ids = []
  CSV.foreach(internet_archive_file, headers: true) do |entry|
    unless entry['identifier']
      raise UserError, "csv files MUST contain a field entitled 'identifier' formatted 'ldpd_########_000'"
    end

    # Match a regex for [PREFIX](.*?)[SUFFIX] and store it in a new array.
    clio_id = entry['identifier'].to_s[/#{IA_IDENTIFIER_PREFIX}(.*?)#{IA_IDENTIFIER_SUFFIX}/m, 1]
    clio_ids << clio_id
  end
  clio_ids
end

# Takes in a url and returns the contents of the file at that url.
def get_file_at_url(url)
  handle_http_error = proc do |exception|
    puts "#{exception.message} (#{url})"
    raise UserError, "File not found: '#{url}'" if exception.message.downcase.include? '404 not found'
  end

  Retriable.retriable(on: OpenURI::HTTPError, tries: 10, on_retry: handle_http_error) do
    URI.parse(url).read
  end
end

# Takes in the ID of an Internet Archive entry and returns its corresponding marc record object.
def get_marc_record(clio_id)
  marc_file_path = "#{MARC_FILE_URL_PREFIX}#{clio_id}#{MARC_FILE_URL_SUFFIX}"

  marc = get_file_at_url(marc_file_path)
  MARC::Reader.decode(marc)
end

# Takes in a 776 $w subfield and returns the ID it contains if it exists.
def print_id_from_subfield(prev, subfield, primary_clio_id)
  return prev unless subfield.include? PRINT_RECORD_IDENTIFIER_PREFIX
  raise UserError, "Multiple print records found for #{primary_clio_id}." if prev

  # Perform a regex match for the ID, ensuring parantheses are escaped.
  subfield[/#{PRINT_RECORD_IDENTIFIER_PREFIX.gsub('(', '\(').gsub(')', '\)')}(.*?)$/m, 1]
end

# Takes in a MARC::Record object and returns its print record ID or nil
def get_print_record_oclc_id(record, primary_clio_id)
  oclc_id = nil
  record.each_by_tag '776' do |field|
    next unless field['w']

    if field['w'].is_a? Array
      field['w'].each { |element| oclc_id = print_id_from_subfield(oclc_id, element, primary_clio_id) }
    else
      oclc_id = print_id_from_subfield(oclc_id, field['w'], primary_clio_id)
    end
  end
  oclc_id
end

# Takes in a print record oclc identifier and retuns its corresponding clio identifier.
def get_print_record_clio_id(oclc_id, primary_clio_id)
  puts OCLC_JSON_PREFIX + oclc_id
  # TODO: fix the url (using ocm at the end or not)
  search_results = JSON.parse get_file_at_url (OCLC_JSON_PREFIX + oclc_id)

  # TODO: Parse 'docs' subsection of json and find the entry that doesn't match primary_clio_id and lookup its marc file
  pp search_results
  -1
end

# Takes in a MARC::Record object and returns [print_record_clio_id, print_record_title] or [nil, nil]
def get_print_record(record, primary_clio_id)
  print_record_oclc_id = get_print_record_oclc_id record, primary_clio_id
  return [nil, nil] unless print_record_oclc_id

  puts "\tfound print record with id #{print_record_oclc_id}"
  # Get MARC for print_record_clio_id, check that 035 $a matches.
  print_record_clio_id = get_print_record_clio_id print_record_oclc_id, primary_clio_id
  puts print_record_clio_id
  # marc = get_marc_record(print_record_clio_id)
  # puts marc
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
  print_record_clio_id, print_record_title = get_print_record record, primary_clio_id

  { primary_clio_id: primary_clio_id, primary_record_title: primary_record_title,
    print_record_clio_id: print_record_clio_id, print_record_title: print_record_title }
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
