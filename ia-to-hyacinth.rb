require 'marc'
require 'csv'

INTERNET_ARCHIVE_IDENTIFIER_PREFIX = 'ldpd_'
INTERNET_ARCHIVE_IDENTIFIER_SUFFIX = '_000'

# Takes as input the expected archive entries and returns list containing just the IDs
def get_internet_archive_ids(internet_archive_entries, id_column)
    puts internet_archive_entries[1][id_column]
    unless internet_archive_entries[1][id_column].to_s.include?(INTERNET_ARCHIVE_IDENTIFIER_PREFIX)
        for id_column in 0...internet_archive_entries[1].length
            if internet_archive_entries[1][id_column].to_s.include?(INTERNET_ARCHIVE_IDENTIFIER_PREFIX)
                break
            end
        end
    end

    internet_archive_ids = []
    puts id_column
    for i in 1...internet_archive_entries.length
        # Match a regex for PREFIX .*? SUFFIX and store it in a new array.
        internet_archive_ids << internet_archive_entries[i][id_column].to_s[/#{INTERNET_ARCHIVE_IDENTIFIER_PREFIX}(.*?)#{INTERNET_ARCHIVE_IDENTIFIER_SUFFIX}/m, 1]
    end
    return internet_archive_ids
end





id_column = 3 # Expected column; will search if it doesn't contain the prefix.

# Path to CSV containing Internet Archive records
internet_archive_file = 'test/MuslimWorldManuscripts.csv'
internet_archive_entries = CSV.read(internet_archive_file)
if internet_archive_entries.length < 2
    raise "File '#{internet_archive_file}' has no entries."
end
internet_archive_ids = get_internet_archive_ids(internet_archive_entries, id_column)
puts internet_archive_ids

