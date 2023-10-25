# frozen_string_literal: true
require 'spec_helper'
require 'ia_to_hyacinth'

# TODO: Make file paths OS-portable.
input_filepath = 'test_files/short.csv'
output_dir = 'test_files'
output_fname = 'tmp_hy'
output_extension = '.csv'

describe CSV_Write do
  before do
    @tempfile = Tempfile.new([output_fname, output_extension], output_dir)
    convert_csv input_filepath, "#{output_dir}/#{output_fname}.csv"
    clio_record_from_id_helper('14734628')
  end

  describe 'csv write' do
    # TODO: Change to use dynamic length of input file to compare file length
    it 'writes the correct number of entries' do
      expect(@tempfile.foreach(filename).inject(0) { |c, _| c + 1 }).to eq(4)
    end
  end
end
