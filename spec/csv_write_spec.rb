# frozen_string_literal: true
require 'spec_helper'
require 'ia_to_hyacinth'

# TODO: Make file paths OS-portable.
input_filepath = 'test_files/Short.csv'
output_dir = 'test_files'
output_fname = 'tmp_hy'
output_extension = '.csv'

describe CSV_Write do
  let(:tempfile) { Tempfile.new([output_fname, output_extension], output_dir) }
  let(:output_filepath) {"#{output_dir}/#{output_fname}.csv"}

  convert_csv input_filepath, "#{output_dir}/#{output_fname}.csv"

  it 'writes the correct number of entries' do
    expect(tempfile.foreach(filename).inject(0) { |c, _| c + 1 }).to eq(4)
  end

  it 'wrote the proper values in an entry' do
    JsonCsv.csv_file_to_hierarchical_json_hash(output_filepath) do |json_hash_for_row, csv_row_number|
      if csv_row_number == 3
        expect(json_hash_for_row['primary_clio_id']).to eq('14678094')
        expect(json_hash_for_row['primary_record_title']).to eq('Collection of Sufi writings and prayers')
        expect(json_hash_for_row['print_record_clio_id']).to eq('14441781')
        expect(json_hash_for_row['print_record_title']).to eq('Collection of Sufi writings and prayers')
      end
    end
  end
end
