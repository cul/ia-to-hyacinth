# frozen_string_literal: true
require 'spec_helper'
require 'ia_to_hyacinth'

describe 'MARC' do
  let(:csv_converter) { IaToHyacinth::CsvConverter.new }
  let(:clio_record) { csv_converter.clio_record_from_id_helper('14734628') }

  it 'parses primary record' do
    expect(clio_record['primary_clio_id']).to eq('14734628')
    expect(clio_record['primary_record_title']).to eq('Persian calligraphy and illustration album')
  end

  it 'parses secondary record' do
    expect(clio_record['print_record_clio_id']).to eq('14011112')
    expect(clio_record['print_record_title']).to eq('Persian calligraphy and illustration album')
  end
end
