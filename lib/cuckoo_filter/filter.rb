module CuckooFilter
  class Filter
    MAX_ATTEMPTS = 500
    DEFAULT_BUCKET_SIZE = 5
    DEFAULT_BUCKETS = 5

    def initialize(buckets: DEFAULT_BUCKETS, bucket_size: DEFAULT_BUCKET_SIZE, max_attempts: MAX_ATTEMPTS)
      @buckets = Array.new(buckets) { [] }
      @bucket_size = bucket_size
      @max_attempts = max_attempts
    end

    def insert(o)
      return if lookup(o)
      (f, i1, i2) = hash_and_fingerprint(o)
      return true if (add_to_bucket(i1, f) || add_to_bucket(i2, f))

      raise CuckooFilter::FullError unless kick [i1, i2].sample, f
      true
    end

    def hash_and_fingerprint(o)
      f = fingerprint o
      i1 = do_hash(o)
      i2 = (i1 ^ do_hash(f)) % @buckets.size
      return f, i1, i2
    end

    def kick(i, f)
      (1..@max_attempts).each do
        random_entry = rand(@bucket_size)
        entry = @buckets[i][random_entry]
        @buckets[i][random_entry] = f
        f = entry
        new_f_i = (i ^ do_hash(f)) % @buckets.size
        return true if (add_to_bucket(new_f_i, f))
      end
      false
    end

    def lookup(o)
      (f, i1, i2) = hash_and_fingerprint(o)
      (@buckets[i1].include? f) || (@buckets[i2].include? f)
    end

    def fingerprint(o)
      o.hash 
    end

    def do_hash(f)
      ((f.hash >> 2) % @buckets.size)
    end

    def delete(o)
      (f, i1, i2) = hash_and_fingerprint(o)
      @buckets[i1].delete(f) || @buckets[i2].delete(f)
    end

    def add_to_bucket(index, value)
      if(@buckets[index].size < @bucket_size)
        @buckets[index].push(value) unless @buckets[index].include?(value)
        return true
      end
      false
    end

    def stats
      buckets = ""
      @buckets.each_with_index do |bucket, i|
        buckets << "Bucket #{i}:\t\t#{sprintf "%.2f%", (bucket.size.to_f / @bucket_size) * 100 }\n"
      end
      buckets
    end
  end
  class FullError < StandardError
  end
end
