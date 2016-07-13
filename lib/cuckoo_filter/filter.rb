require 'digest/murmurhash'

module Cuckoo
  class Filter
    MAX_ATTEMPTS = 500
    DEFAULT_BUCKET_SIZE = 4
    DEFAULT_BUCKETS = 5
    DEFAULT_FINGERPRINT_BITS = 16
    BLOCK_ATTEMPTS = 3

    def initialize(buckets: DEFAULT_BUCKETS, bucket_size: DEFAULT_BUCKET_SIZE,
                   max_attempts: MAX_ATTEMPTS, bits: DEFAULT_FINGERPRINT_BITS,
                   cuckoo_block: false, cuckoo_block_attempts: BLOCK_ATTEMPTS)
      @buckets = Array.new(buckets) { [] }
      @bucket_size = bucket_size
      @max_attempts = max_attempts
      @fingerprint_bits = bits
      @cuckoo_block = cuckoo_block
      @cuckoo_block_attempts = cuckoo_block_attempts
    end

    def insert(o)
      return 'already present' if lookup(o)
      (f, i1, i2) = hash_and_fingerprint(o)
      return true if add_to_bucket(i1, f) || add_to_bucket(i2, f)
      raise Cuckoo::FullError unless kick [i1, i2].sample, f
      true
    end

    def lookup(o)
      (f, i1, i2) = hash_and_fingerprint(o)
      (@buckets[i1].include? f) || (@buckets[i2].include? f)
    end

    def delete(o)
      (f, i1, i2) = hash_and_fingerprint(o)
      @buckets[i1].delete(f) || @buckets[i2].delete(f)
    end

    def stats
      buckets = ''
      @buckets.each_with_index do |bucket, i|
        buckets << "Bucket #{i}:\t\t"
        buckets << format('%.2f%', (bucket.size.to_f / @bucket_size) * 100)
        buckets << "\n"
      end
      buckets
    end

    private

    def hash_and_fingerprint(o)
      hash = hash1(o)
      f = fingerprint hash
      i2 = (hash ^ hash2(f))
      [f, index(hash), index(i2)]
    end

    def index(i)
      i % @buckets.size
    end

    def kick(i, f)
      (1..@max_attempts).each do |attempt|
        random_entry = rand(@bucket_size)
        entry = @buckets[i][random_entry]
        @buckets[i][random_entry] = f
        f = entry
        new_f_index = get_next_bucket(i, f, attempt)
        return true if add_to_bucket(new_f_index, f)
      end
      false
    end

    def get_next_bucket(i, f, attempt)
      #return i + attempt if @cuckoo_block && (attempt < @cuckoo_block_attempts)
      index(i ^ hash2(f))
    end

    def fingerprint(o)
      o & ((1 << @fingerprint_bits) - 1)
    end

    def hash1(f)
      Digest::MurmurHash64A.rawdigest(f.to_s)
    end

    def hash2(f)
      Digest::MurmurHash64B.rawdigest(f.to_s)
    end

    def add_to_bucket(index, value)
      if @buckets[index].size < @bucket_size
        @buckets[index].push(value) unless @buckets[index].include?(value)
        return true
      end
      false
    end
  end
  class FullError < StandardError
  end
end
