require 'marc'
require 'csv'

INTERNET_ARCHIVE_IDENTIFIER_PREFIX = 'ldpd_'
INTERNET_ARCHIVE_IDENTIFIER_SUFFIX = '_000'

# Takes as input the expected archive entries and returns list containing just the IDs
def get_internet_archive_ids(internet_archive_entries, id_column)
    puts internet_archive_entries[1][id_column]
    unless internet_archive_entries[1][id_column].to_s.include?(INTERNET_ARCHIVE_IDENTIFIER_PREFIX)
        internet_archive_entries[1].each_with_index do |element, i|
            if element.to_s.include?(INTERNET_ARCHIVE_IDENTIFIER_PREFIX)
                id_column = i
            end
        end
    end

    internet_archive_ids = []
    puts id_column
    internet_archive_entries.each do |entry|
        # Match a regex for PREFIX .*? SUFFIX and store it in a new array.
        internet_archive_ids << entry[id_column].to_s[/#{INTERNET_ARCHIVE_IDENTIFIER_PREFIX}(.*?)#{INTERNET_ARCHIVE_IDENTIFIER_SUFFIX}/m, 1]
    end
    return internet_archive_ids
end





id_column = 2 # Expected column; will search if it doesn't contain the prefix.

# Path to CSV containing Internet Archive records
internet_archive_file = 'test/MuslimWorldManuscripts.csv'
internet_archive_entries = CSV.read(internet_archive_file)
if internet_archive_entries.length < 2
    raise "File '#{internet_archive_file}' has no entries."
end
internet_archive_ids = get_internet_archive_ids(internet_archive_entries, id_column)
puts internet_archive_ids

