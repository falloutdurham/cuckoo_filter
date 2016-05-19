require 'spec_helper'

describe CuckooFilter do
  it 'has a version number' do
    expect(CuckooFilter::VERSION).not_to be nil
  end

  it 'does something useful' do
    a = CuckooFilter::Filter.new(bit_size: 5)
    
  end
end
