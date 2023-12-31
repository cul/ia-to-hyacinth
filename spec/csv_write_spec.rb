# frozen_string_literal: true

require 'tempfile'
require 'spec_helper'
require 'ia_to_hyacinth'

# TODO: Make file paths OS-portable.
output_fname_prefix = 'tmp_hy'
output_extension = '.csv'

describe 'CSV_Writing' do
  let(:csv_output_tempfile) { Tempfile.new([output_fname_prefix, output_extension]) }
  let(:csv_converter) { IaToHyacinth::CsvConverter.new }

  before do
    csv_converter.convert_csv(fixture('Short.csv').path, csv_output_tempfile)
  end

  after do
    # It's good practice to close (and unlink) a tempfile as soon as possible
    csv_output_tempfile.close!
  end

  it 'writes the correct number of entries' do
    expect(csv_output_tempfile.read.count("\n")).to eq(4)
  end

  it 'writes the proper values in an entry' do
    JsonCsv.csv_file_to_hierarchical_json_hash(csv_output_tempfile.path) do |json_hash_for_row, csv_row_number|
      if csv_row_number == 3
        expect(json_hash_for_row['primary_clio_id']).to eq('14678094')
        expect(json_hash_for_row['primary_record_title']).to eq('Collection of Sufi writings and prayers')
        expect(json_hash_for_row['print_record_clio_id']).to eq('14441781')
        expect(json_hash_for_row['print_record_title']).to eq('Collection of Sufi writings and prayers')
      end
    end
  end
end
