# AnyCache &middot; [![Gem Version](https://badge.fury.io/rb/any_cache.svg)](https://badge.fury.io/rb/any_cache) [![Build Status](https://travis-ci.org/0exp/any_cache.svg?branch=master)](https://travis-ci.org/0exp/any_cache) [![Coverage Status](https://coveralls.io/repos/github/0exp/any_cache/badge.svg?branch=master)](https://coveralls.io/github/0exp/any_cache?branch=master)

AnyCache - a simplest cache wrapper that provides a minimalistic generic interface for all well-known cache storages and includes a minimal set of necessary operations:
`fetch`, `read`, `write`, `delete`, `fetch_multi`, `read_multi`, `write_multi`, `delete_matched`, `expire`, `persist`, `exist?`, `clear`, `cleanup`, `increment`, `decrement`.

Supported clients:

- `Redis` ([gem redis](https://github.com/redis/redis-rb)) ([redis storage](https://redis.io/))
- `Redis::Store` ([gem redis-store](https://github.com/redis-store/redis-store)) ([redis storage](https://redis.io/))
- `Dalli::Client` ([gem dalli](https://github.com/petergoldstein/dalli)) ([memcached storage](https://memcached.org/))
- `ActiveSupport::Cache::RedisCacheStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/redis_cache_store.rb)) ([redis cache storage](https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html))
- `ActiveSupport::Cache::DalliStore` ([gem dalli](https://github.com/petergoldstein/dalli)) ([dalli store](https://github.com/petergoldstein/dalli/blob/master/lib/active_support/cache/dalli_store.rb))
- `ActiveSupport::Cache::MemCacheStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/mem_cache_store.rb)) ([memcache storage](https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html))
- `ActiveSupport::Cache::FileStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/file_store.rb)) ([file storage](https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html))
- `ActiveSupport::Cache::MemoryStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/memory_store.rb)) ([in memory storage](https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html))

- [Coming Soon] Simple in-memory hash-based cache client

---

## Installation

```ruby
gem 'any_cache'
```

```shell
bundle install
# --- or ---
gem install any_cache
```

```ruby
require 'any_cache'
```

---

## Usage / Table of Contents

- [Creation](#creation)
    - [Manual creation](#manual-creation)
    - [Config-based creation](#config-based-creation)
        - [AnyCache with Redis](#anycache-with-redis)
        - [AnyCache with Redis::Store](#anycache-with-redisstore)
        - [AnyCache with Dalli::Client](#anycache-with-dalliclient)
        - [AnyCache with ActiveSupport::Cache::RedisCacheStore](#anycache-with-activesupportcacherediscachestore)
        - [AnyCache with ActiveSupport::Cache::DalliStore](#anycache-with-activesupportcachedallistore)
        - [AnyCache with ActiveSupport::Cache::MemCacheStore](#anycache-with-activesupportcachememcachestore)
        - [AnyCache with ActiveSupport::Cache::FileStore](#anycache-with-activesupportcachefilestore)
        - [AnyCache with ActiveSupport::Cache::MemoryStore](#anycache-with-activesupportcachememorystore)
    - [Many cache storages](#many-cache-storages)
    - [Custom cache clients](#custom-cache-clients)
- [Logging](#logging)
- [Operations](#operations)
    - [Fetch](#fetch) / [Fetch Multi](#fetch-multi)
    - [Read](#read) / [Read Multi](#read-multi)
    - [Write](#write) / [Write Multi](#write-multi)
    - [Delete](#delete) / [Delete Matched](#delete-matched)
    - [Increment](#increment) / [Decrement](#decrement)
    - [Expire](#expire)
    - [Persist](#persist)
    - [Existence](#existence)
    - [Clear](#clear)
    - [Cleanup](#cleanup)
- [Plugins](#plugins)
- [Roadmap](#roadmap)

---

### Creation

To instantiate AnyCache instance you have to provide a client.
Client - an independent driver that works with a corresponding cache storage (external dependency).

Supported clients:

- `Redis`
- `Redis::Store`
- `Dalli::Client`
- `ActiveSupport::Cache::RedisCacheStore`
- `ActiveSupport::Cache::DalliStore`
- `ActiveSupport::Cache::MemCacheStore`
- `ActiveSupport::Cache::FileStore`
- `ActiveSupport::Cache::MemoryStore`

`AnyCache` can be instantiated by two ways:

- with explicit client object instantiated manually ([read](#manual-creation));
- via configuration ([read](#config-based-creation));

#### Manual creation

Custom instantiation with explicit client objects:

```ruby
# 1) create client object
client = Redis.new(...)
# -- or --
client = Redis::Store.new(...)
# -- or --
client = Dalli::Client.new(...)
# -- or --
client = ActiveSupport::Cache::RedisCacheStore.new(...)
# -- or --
client = ActiveSupport::Cache::DalliStore.new(...)
# -- or --
client = ActiveSupport::Cache::MemCacheStore.new(...)
# -- or --
client = ActiveSupport::Cache::FileStore.new(...)
# -- or --
client = ActiveSupport::Cache::MemoryStore.new(...)

# 2) build AnyCache instance
cache_store = AnyCache.build(client) # => <AnyCache:0x00007f990527f268 ...>
```

#### Config-based creation

You can configure `AnyCache` globally or create subclasses and configure each of them. After that
storage instantiation works via `.build` method without explicit attributes.

- `AnyCache.configure` is used for configuration;
- `config.driver` is used for determine which client should be used;
- `config.__driver_name__.options` stores client-related options;

Supported drivers:

- `:redis` - [Redis](#anycache-with-redis);
- `:redis_store` - [Redis::Client](#anycache-with-redisstore);
- `:dalli` - [Dalli::Client](#anycache-with-dalliclient);
- `:as_redis_cache_store` - [ActiveSupport::Cache::RedisCacheStore](#anycache-with-activesupportcacherediscachestore);
- `:as_dalli_store` - [ActiveSupport::Cache::DalliStore](#anycache-with-activesupportcachedallistore);
- `:as_mem_cache_store` - [ActiveSupport::Cache::MemCacheStore](#anycache-with-activesupportcachememcachestore);
- `:as_file_store` - [ActiveSupport::Cache::FileStore](#anycache-with-activesupportcachefilestore);
- `:as_memory_store` - [ActiveSupport::Cache::MemoryStore](#anycache-with-activesupportcachememorystore);

##### `AnyCache` with `Redis`:

```ruby
require 'redis'
require 'any_cache'

AnyCache.configure do |conf|
  conf.driver = :redis
  conf.redis.options = { ... } # Redis-related options
end

cache_store = AnyCache.build
```

##### `AnyCache` with `Redis::Store`:

```ruby
require 'redis-store'
require 'any_cache'

AnyCache.configure do |conf|
  conf.driver = :redis_store
  conf.redis_store.options = { ... } # Redis::Store-related options
end

cache_store = AnyCache.build
```

##### `AnyCache` with `Dalli::Client`:

```ruby
require 'dalli'
require 'any_cache'

AnyCache.configure do |conf|
  conf.driver = :dalli
  conf.dalli.servers = ... # string or array of strings
  conf.dalli.options = { ... } # Dalli::Client-related options
end

cache_store = AnyCache.build
```

##### `AnyCache` with `ActiveSupport::Cache::RedisCacheStore`:

```ruby
require 'redis'
require 'active_support'
require 'any_cache'

AnyCache.configure do |conf|
  conf.driver = :as_redis_cache_store
  conf.as_redis_cache_store.options = { ... } # ActiveSupport::Cache::RedisCacheStore-related options
end

cache_store = AnyCache.build
```

##### `AnyCache` with `ActiveSupport::Cache::DalliStore`:

```ruby
require 'dalli'
require 'active_support'
require 'any_cache'

AnyCache.enable_patch!(:dalli_store) # NOTE: actual for Dalli <= 2.7.8

AnyCache.configure do |conf|
  conf.driver = :as_dalli_store
  conf.as_dalli_store.servers = ... # string or array of strings
  conf.as_dalli_store.options = { ... } # ActiveSupport::Cache::DalliStore-related options
end

cache_store = AnyCache.build
```

##### `AnyCache` with `ActiveSupport::Cache::MemCacheStore`:

```ruby
require 'active_support'
require 'any_cache'

AnyCache.configure do |conf|
  conf.driver = :as_mem_cache_store
  conf.as_mem_cache_store.servers = ... # string or array of strings
  conf.as_mem_cache_store.options = { ... } # ActiveSupport::Cache::MemCacheStore-related options
end

cache_store = AnyCache.build
```

##### `AnyCache` with `ActiveSupport::Cache::FileStore`:

```ruby
require 'active_support'
require 'any_cache'

AnyCache.configure do |conf|
  conf.driver = :as_file_store
  conf.as_file_store.cache_path = '/path/to/cache'
  conf.as_file_store.options = { ... } # ActiveSupport::Cache::FileStore-related options
end

cache_store = AnyCache.build
```

##### `AnyCache` with `ActiveSupport::Cache::MemoryStore`:

```ruby
require 'activesupport'
require 'any_cache'

AnyCache.configure do |conf|
  conf.driver = :as_memory_store
  conf.as_memory_store.options = { ... } # ActiveSupport::Cache::MemoryStore-related options
end

cache_store = AnyCache.build
```

#### Many cache storages

You can inherit `AnyCache` class and create and configure as many cache storages as you want:

```ruby
class RedisCache < AnyCache
  configure do |conf|
    conf.driver = :redis
  end
end

class DalliCache < AnyCache
  configure do |conf|
    conf.driver = :dalli
  end
end

redis_cache = RedisCache.build
dalli_cache = DalliCache.build
```

#### Custom cache clients

If you want to use your own cache client implementation, you should provide an object that responds to:

- `#fetch(key, [**options])` ([doc](#fetch))
- `#fetch_multi(*keys, [**options])` ([doc](#fetch-multi))
- `#read(key, [**options])` ([doc](#read))
- `#read_multi(*keys, [**options])` ([doc](#read-multi))
- `#write(key, value, [**options])` ([doc](#write))
- `#write_multi(entries, [**options])` ([doc](#write-multi))
- `#delete(key, [**options])` ([doc](#delete))
- `#delete_matched(pattern, [**options])` ([doc](#delete-matched))
- `#increment(key, amount, [**options])` ([doc](#increment))
- `#decrement(key, amount, [**options])` ([doc](#decrement))
- `#expire(key, [**options])` ([doc](#expire))
- `#persist(key, [**options])` ([doc](#persist))
- `#exist?(key, [**options])` ([doc](#existence))
- `#clear([**options])` ([doc](#clear))
- `#cleanup([**options])` ([doc](#cleanup))

```ruby
class MyCacheClient
  # ...

  def read(key, **)
    # ...
  end

  def write(key, value, **)
    # ...
  end

  # ...
end

AnyCache.build(MyCacheClient.new)
```

---

### Logging

AnyCache logs all its operations. By default, `AnyCache` uses a simple `STDOUT` logger with `Logger::INFO` level.
Logging is performed with level configured in logger object.

Logger configuration:

```ruby
# --- use your own logger ---
AnyCache.configure do |conf|
  conf.logger = MyLoggerObject.new
end

# --- disable logging ---
AnyCache.configure do |conf|
  conf.logger = nil
end

# --- (used by default) ---
AnyCache.configure do |conf|
  conf.logger = AnyCache::Logging::Logger.new(STDOUT)
end

# --- (your cache client inherited from AnyCache) ---
YourCacheClient.configure do |conf|
  # same configs as above
end
```

Log message format:

```shell
[AnyCache<CACHER_NAME>/Activity<OPERATION_NAME>]: performed <OPERATION_NAME> operation with
params: INSPECTED_ARGUMENTS and options: INSPECTED_OPTIONS
```

- progname
  - `CACHER_NAME` - class name of your cache class;
  - `OPERATION_NAME` - performed operation (`read`, `write`, `fetch` and etc);
- message
  - `INSPECTED_ARGUMENTS` - a set of operation arguments;
  - `INSPECTED_OPTIONS` - a set of operation options;

```ruby
any_cache.write("data", 123, expires_in: 60)
# I, [2018-09-07T10:04:56.649960 #15761]  INFO -- [AnyCache<AnyCache>/Activity<write>]: performed <write> operation with attributes: ["data", 123] and options: {:expires_in=>60}.

any_cache.clear
# I, [2018-09-07T10:05:26.999847 #15761]  INFO -- [AnyCache<AnyCache>/Activity<clear>]: performed <clear> operation with attributes: [] and options: {}.
```

## Operations

`AnyCache` provides a following operation set:

- [fetch](#fetch) / [fetch_multi](#fetch-multi)
- [read](#read) / [read_multi](#read-multi)
- [write](#write) / [write_multi](#write-multi)
- [delete](#delete) / [delete_matched](#delete-matched)
- [increment](#increment) / [decrement](#decrement)
- [expire](#expire)
- [persist](#persist)
- [clear](#clear)
- [exist?](#existence)

---

### Fetch

- `AnyCache#fetch(key, [force:], [expires_in:], [&fallback])`
    - works in `ActiveSupport::Cache::Store#fetch`-manner;
    - fetches data from the cache using the given key;
    - if a `fallback` block has been passed and data with the given key does not exist - that block
      will be called with the given key and the return value will be written to the cache;
    - use `raw: true` if you want to fetch incrementable/decrementable entry;

```ruby
# --- entry exists ---
cache_store.fetch("data") # => "some_data"
cache_store.fetch("data") { "new_data" } # => "some_data"

# --- entry does not exist ---
cache_store.fetch("data") # => nil
cache_store.fetch("data") { |key| "new_data" } # => "new_data"
cache_store.fetch("data") # => "new_data"

# --- new entry with expiration time ---
cache_store.fetch("data") # => nil
cache_store.fetch("data", expires_in: 8) { |key| "new_#{key}" } # => "new_data"
cache_store.fetch("data") # => "new_data"
# ...sleep 8 seconds...
cache_store.fetch("data") # => nil

# --- force update/rewrite ---
cache_store.fetch("data") # => "some_data"
cache_store.fetch("data", expires_in: 8, force: true) { |key| "new_#{key}" } # => "new_data"
cache_store.fetch("data") # => "new_data"
# ...sleep 8 seconds...
cache_store.fetch("data") # => nil
```

---

### Fetch Multi

- `AnyCache#fetch_multi(*keys, [force:], [expires_in:], [&fallback])`
    - get a set of entries in hash form from the cache storage using given keys;
    - works in `#fetch` manner but with a series of entries;
    - nonexistent entries will be fetched with `nil` values;
    - use `raw: true` if you want to fetch incrementable/decrementable entries;

```ruby
# --- fetch entries ---
cache_store.fetch_multi("data", "second_data", "last_data")
# => returns:
{
  "data" => "data", # existing entry
  "second_data" => nil, # nonexistent entry
  "last_data" => nil # nonexistent entry
}

# --- fetch etnries and define non-existent entries ---
cache_store.fetch_multi("data", "second_data", "last_data") { |key| "new_#{key}" }
# => returns:
{
  "data" => "data", # entry with OLD value
  "second_data" => "new_second_data", # entry with NEW DEFINED value
  "last_data" => "new_last_data" # entry with NEW DEFINED value
}

# --- force rewrite all entries ---
cache_store.fetch_multi("data", "second_data", "last_data", force: true) { |key| "force_#{key}" }
# => returns
{
  "data" => "force_data", # entry with REDEFINED value
  "second_data" => "force_second_data", # entry with REDEFINED value
  "last_data" => "force_last_data" # entry with REDEFINED value
}
```

---

### Read

- `AnyCache#read(key)` - get an entry value from the cache storage
  - pass `raw: true` if you want to read incrementable/decrementable entries;

```ruby
# --- entry exists ---
cache_store.read("data") # => "some_data"

# --- entry doesnt exist ---
cache_store.read("data") # => nil

# --- read incrementable/decrementable entry ---
cache_store.read("data", raw: true) # => "2" (for example)
```

---

### Read Multi

- `AnyCache#read_multi(*keys)`
    - get entries from the cache storage in hash form;
    - nonexistent entries will be fetched with `nil` values;
    - pass `raw: true` if you want to read incrementable/decrementable entries;

```ruby
cache_store.read_multi("data", "another_data", "last_data", "super_data")
# => returns
{
  "data" => "test", # existing entry
  "another_data" => nil, # nonexistent entry
  "last_data" => "some_data", # exisitng enry
  "super_data" => nil # existing entry
}

# --- read incrementable/decrementable entries ---
cache_store.read_multi("data", "another_data", raw: true)
# => returns
{
  "data" => "1",
  "another_data" => "2",
}
```

---

### Write

- `AnyCache#write(key, value, [expires_in:])` - write a new entry to the cache storage;
  - pass `raw: true` if you want to store incrementable/decrementable entries;

```ruby
# --- permanent entry ---
cache_store.write("data", 123)

# --- temporal entry (expires in 60 seconds) ---
cache_store.write("data", 123, expires_in: 60)

# --- incrementable/decrementable entry ---
cache_store.write("data", 123, raw: true)
```

---

### Write Multi

- `AnyCache#write_multi(**entries)` - write a set of permanent entries to the cache storage;
  - pass `raw: true` if you want to store incrementable/decrementable entries;

```ruby
cache_store.write_multi("data" => "test", "another_data" => 123)

# --- incrementable/decrementable entries ---
cache_store.write_multi("data" => 1, "another_data" => 2, raw: true)
```

---

### Delete

- `AnyCache#delete(key)` - remove entry from the cache storage;

```ruby
cache_store.delete("data")
```

---

### Delete Matched

- `AnyCache#delete_matched(pattern)`
    - removes all entries with keys matching the pattern;
    - currently unsupported: `:dalli`, `:as_mem_cache_store`, `:as_dalli_store`;

```ruby
# --- using a regepx ---
cache_store.delete_matched(/\A*test*\z/i)

# --- using a string ---
cache_store.delete_matched("data")
```

---

### Increment

- `AnyCache#increment(key, amount = 1, [expires_in:])` - increment entry's value by the given amount
  and set the new expiration time if needed;
  - can increment only nonexistent entries OR entries that were written with `raw: true` option;

```ruby
# --- increment existing entry ---
cache_store.write("data", 1, raw: true) # you must provide :raw => true for incrementable entries

# --- increment by default value (1) ---
cache_store.increment("data") # => 2

# --- increment by custom value ---
cache_store.increment("data", 12) # => 14

# --- increment and expire after 31 seconds
cache_store.incrmeent("data", expires_in: 31) # => 15

# --- increment nonexistent entry (create new entry) ---
cache_store.increment("another_data", 5, expires_in: 5) # => 5

# --- read incrementable entry ---
cache_store.read("data", raw: true) # you must provide :raw => true for incrementable entries
```

---

### Decrement

- `AnyCache#decrement(key, amount = 1, [expires_in:])` - decrement entry's value by the given amount
  and set the new expiration time if needed;
  - can decrement only nonexistent entries OR entries that were written with `raw: true` option;

```ruby
# --- decrement existing entry ---
cache_store.write("data", 15, raw: true) # you must provide :raw => true for decrementable entries

# --- decrement by default value (1) ---
cache_store.decrement("data") # => 14

# --- decrement by custom value ---
cache_store.decrement("data", 10) # => 4

# --- decrement and expire after 5 seconds
cache_store.decrememnt("data", expirs_in: 5) # => 3

# --- decrement nonexistent entry (create new entry) ---
cache_store.decrememnt("another_data", 2, expires_in: 10) # => -2 (or 0 for Dalli::Client)

# --- read decrementable entry ---
cache_store.read("data", raw: true) # you must provide :raw => true for decrementable entries
```

---

### Expire

- `AnyCache#expire(key, [expires_in:])` - expire entry immediately or set the new expiration time;

```ruby
# --- expire immediately ---
cache_store.expire("data")

# --- set new expiration time (in seconds) --
cache_store.expire("data", expires_in: 36)
```

---

### Persist

- `AnyCache#persist(key)` - change entry's expiration time to permanent;

```ruby
# --- create temporal entry (30 seconds) ---
cache_store.write("data", { a: 1 }, expires_in: 30)

# --- remove entry expiration (make it permanent) ---
cache_store.persist("data")
```

---

### Existence

- `AnyCache#exist?(key)` - determine if an entry exists;

```ruby
# --- entry exists ---
cache_store.exist?("data") # => true

# --- entry does not exist ---
cache_store.exist?("another-data") # => false
```

---

### Clear

- `AnyCache#clear()` - clear cache database;

```ruby
# --- prepare cache data ---
cache_store.write("data", { a: 1, b: 2 })
cache_store.write("another_data", 123_456)

cache_store.read("data") # => { a: 1, b: 2 }
cache_store.read("another_data") # => 123_456

# --- clear cache ---
cache_store.clear

cache_store.read("data") # => nil
cache_store.read("another_data") # => nil
```

---

### Cleanup

- `AnyCache#cleanup()` - remove expired entries from cache database
  (make sense only for `:as_file_store` and `:as_memory_store` cache clients);

```ruby
# --- prepare cache data ---
cache_store.write("data", "123", expires_in: 5)
cache_store.write("another_data", "456", expires_in: 10)

# --- waiting for cache exiration (10 seconds) ---
cache_store.cleanup # remove expired entries from database (release disk space for example)
```

---

## Plugins

`AnyCache` provides a set of plugins and an interface for controllable plugin registering and loading.

```ruby
# --- show names of registered plugins ---
AnyCache.plugins # => array of strings

# --- load specific plugin ---
AnyCache.plugin(:plugin_name) # or AnyCache.plugin('plugin_name')
```

---

## Build

- see [bin/rspec](bin/rspec)

```shell
bin/rspec --test-redis # run specs with Redis
bin/rspec --test-redis-store # run specs with Redis::Store
bin/rspec --test-dalli # run specs with Dalli::Client
bin/rspec --test-as-redis-cache-store # run specs with ActiveSupport::Cache::RedisCacheStore
bin/rspec --test-as-dalli-store # run specs with ActiveSupport::Cache::DalliStore
bin/rspec --test-as-mem-cache-store # run specs with ActiveSupport::Cache::MemCacheStore
bin/rspec --test-as-file-store # run specs with ActiveSupport::Cache::FileStore
bin/rspec --test-as-memory-store # run specs with ActiveSupport::Cache::MemoryStore
```

---

## Roadmap

- instrumentation layer;
- global and configurable default expiration time;
- `#delete_matched` for memcached-based cache storages;
- rails integration;

---

## Contributing

- Fork it (https://github.com/0exp/any_cache/fork)
- Create your feature branch (`git checkout -b feature/my-new-feature`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin feature/my-new-feature`)
- Create new Pull Request

## License

Released under MIT License.

## Authors

Created by [Rustam Ibragimov](https://github.com/0exp/)
