module CuckooFilter
  class Filter
    MAX_ATTEMPTS = 500
    DEFAULT_SIZE = 5

    def initialize(bucket_size: DEFAULT_SIZE, max_attempts: MAX_ATTEMPTS)
      @buckets = Array.new(bucket_size) { 0 }
      @max_attempts = max_attempts
    end

    def insert(o)
      return if self.lookup(o)
      (f,i1,i2) = hash_and_fingerprint(o)
      return true if (replace(i1, f, 0) || replace(i2, f, 0))

      raise CuckooFilter::FullError unless kick [i1,i2].sample, f
      true
    end

    def hash_and_fingerprint(o)
      f = fingerprint o
      i1 = do_hash(o)
      i2 = (i1 ^ do_hash(f)) % @buckets.size
      return f,i1,i2
    end

    def kick(bucket, f)
      (1 .. @max_attempts).each do
        i = rand(@buckets.size)
        e = @buckets[i]
        @buckets[i] = f
        f = e
        i = (i ^ do_hash(f)) % @buckets.size
        return true if replace(i, f, 0)    
      end
      false
    end

    def lookup(o)
      (f,i1,i2) = hash_and_fingerprint(o)
      (@buckets[i1] == f) || (@buckets[i2] == f)
    end

    def fingerprint(o)
      o.hash 
    end

    def do_hash(f)
      ((f.hash >> 2) % @buckets.size)
    end

    def delete(o)
      (f,i1,i2) = hash_and_fingerprint(o)
      replace(i1, 0, f) || replace(i2, 0, f)
    end

    def replace(index, value, value_to_check)
      if(@buckets[index] == value_to_check)
        @buckets[index] = value
        return true
      end
      false
    end

    def stats
      empty = @buckets.select { |x| x == 0 }.size
      occupied = @buckets.size - empty
      "Total: #{@buckets.size} Empty: #{empty} Occupied: #{occupied} %: #{ sprintf "%.2f%", (occupied.to_f / @buckets.size * 100)}"
    end
  end
  class FullError < StandardError
  end
end