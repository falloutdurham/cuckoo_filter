module CuckooFilter
  class Filter
    attr_accessor :buckets
    MAX_ATTEMPTS = 500
    DEFAULT_SIZE = 5
    @max_attempts = MAX_ATTEMPTS

    def initialize(bit_size: DEFAULT_SIZE)
      @buckets = Array.new(bit_size) { 0 }
    end

    def insert(o)
      return if self.lookup(o)
      f = fingerprint o
      i1 = do_hash(o)
      i2 = (i1 ^ do_hash(f)) % @buckets.size
      puts [f, i1, i2]
 
      if (@buckets[i1] == 0)
        @buckets[i1] = f
        return
      end

      if (@buckets[i2] == 0)
        @buckets[i2] = f
        return
      end

      raise CuckooFilter::FullError unless kick [i1,i2].sample, f
    end

    def kick(bucket, f)
      (0..MAX_ATTEMPTS).each do |x|
        i = rand(@buckets.count)
        e = @buckets[i]
        @buckets[i] = f
        f = e
        i = (i ^ do_hash(f)) % @buckets.size
        if @buckets[i] == 0
          @buckets[i] = f
          return true
        end
        
      end
      false
    end

    def lookup(obj)
      f = fingerprint(obj)
      i1 = do_hash(obj)
      i2 = (i1 ^ do_hash(f)) % @buckets.size
      (@buckets[i1] == f) || (@buckets[i2] == f)
    end

    def fingerprint(obj)
      obj.hash 
    end

    def do_hash(f)
      ((f.hash << 2) % @buckets.size)
    end

    def delete(obj)
      f = fingerprint(obj)
      i1 = do_hash(obj)
      i2 = (i1 ^ do_hash(f)) % @buckets.size
      if (@buckets[i1] == f)
        @buckets[i1] = 0
      end
      if (@buckets[i2] == f)
        @buckets[i2] = 0
      end
    end
  end
  a = CuckooFilter::Filter.new ; a.insert("Fff")

  class FullError < StandardError
  end
end