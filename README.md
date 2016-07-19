# CuckooFilter

Ruby implementation of a [Cuckoo Filter](https://www.cs.cmu.edu/%7Edga/papers/cuckoo-conext2014.pdf)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cuckoo_filter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cuckoo_filter

## Usage


    filter = Cuckoo::Filter.new
    filter.insert("key")
    filter.lookup("key") => true
    filter.lookup("not_a_key") => false
    filter.delete("key")
    filter.lookup("key") => false


Options for filter:

  * buckets: amount of buckets to use (default: 5)
  * bucket_size: maximum keys to store in each bucket (default: 4)
  * max_attempts: maximum attempts to find new entry (default: 500)
  * bits: bits of hash to store in bucket (default: 16)

You're likely to need to change `buckets` if nothing else.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/falloutdurham/cuckoo_filter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

