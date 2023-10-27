# frozen_string_literal: true
require 'spec_helper'
require 'ia_to_hyacinth'

# TODO: Make file paths OS-portable.
input_filepath = 'spec/test_files/Short.csv'
output_filepath = 'spec/test_files/tmp_hy.csv'

describe 'CSV Write' do
  let(:tempfile) { File.open(output_filepath) }

  convert_csv input_filepath, output_filepath

  after(:all) do
    # Clean up temporary file
    File.delete(output_filepath)
  end

  it 'writes the correct number of entries' do
    expect(tempfile.read.count("\n")).to eq(4)
  end

  it 'writes the proper values in an entry' do
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
