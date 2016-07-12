require 'spec_helper'
require 'objspace'

describe CuckooFilter do

  let(:filter) { CuckooFilter::Filter.new }

  it 'has a version number' do
    expect(CuckooFilter::VERSION).not_to be nil
  end

  it 'can insert an entry into the cuckoo filter' do
    expect(filter.insert("ff")).to be true
  end

  it 'can look up an entry in the filter and report true if found' do
    expect(filter.insert("ff")).to be true
    expect(filter.lookup("ff")).to be true
  end

  it 'will report false if an entry is not present' do
    expect(filter.lookup("fg")).to be false
  end

  it 'can delete an entry from the cuckoo filter' do
    expect(filter.insert("ff")).to be true
    filter.delete("ff")
    expect(filter.lookup("ff")).to be false
  end

  it 'raises an error when full' do
    a = CuckooFilter::Filter.new(buckets: 2, bucket_size: 1, max_attempts: 10)
    a.insert("ff")
    a.insert("fn")
    expect{a.insert("fh")}.to raise_error(CuckooFilter::FullError)
  end

  it 'prints stats' do
    a = CuckooFilter::Filter.new(buckets:6, bucket_size: 1000)
    (1 .. 5000).each do |x|
      a.insert x
    end
    expect(a.stats).not_to be ""
  end

end
