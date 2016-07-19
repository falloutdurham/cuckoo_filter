require 'spec_helper'
require 'objspace'

describe Cuckoo::Filter do
  let(:filter) { Cuckoo::Filter.new }

  it 'has a version number' do
    expect(Cuckoo::VERSION).not_to be nil
  end

  it 'can insert an entry into the cuckoo filter' do
    expect(filter.insert('ff')).to be true
    expect(filter.insert('bbbc')).to be true
  end

  it 'can look up an entry in the filter and report true if found' do
    expect(filter.insert('ff')).to be true
    expect(filter.lookup('ff')).to be true
  end

  it 'will report false if an entry is not present' do
    expect(filter.lookup('fg')).to be false
  end

  it 'can delete an entry from the cuckoo filter' do
    expect(filter.insert('ff')).to be true
    filter.delete('ff')
    expect(filter.lookup('ff')).to be false
  end

  it 'raises an error when full' do
    a = Cuckoo::Filter.new(buckets: 2, bucket_size: 1, max_attempts: 10)
    a.insert('ff')
    a.insert('fn')
    expect { a.insert('fh') }.to raise_error(Cuckoo::FullError)
  end

  it 'prints stats' do
    a = Cuckoo::Filter.new(buckets: 4000)
    (1..5_000).each { |x| a.insert x }
    expect(a.stats).to match(/Bucket 0:\t\t.*/)
  end

  it 'works in adjacent block mode when asked' do
    a = Cuckoo::Filter.new(buckets: 4000, cuckoo_block: true)
    (1..5_000).each do |x|
      a.insert x
    end
  end
end
