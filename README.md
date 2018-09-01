# AnyCache &middot; [![Gem Version](https://badge.fury.io/rb/any_cache.svg)](https://badge.fury.io/rb/any_cache) [![Build Status](https://travis-ci.org/0exp/any_cache.svg?branch=master)](https://travis-ci.org/0exp/any_cache) [![Coverage Status](https://coveralls.io/repos/github/0exp/any_cache/badge.svg)](https://coveralls.io/github/0exp/any_cache)

AnyCache - a simplest cache wrapper that provides a minimalistic generic interface for all well-known cache storages and includes a minimal set of necessary operations:
`read`, `write`, `delete`, `expire`, `persist`, `clear`, `increment`, `decrement`.

Supported clients:

- `Redis` ([gem redis](https://github.com/redis/redis-rb)) ([redis storage](https://redis.io/))
- `Redis::Store` ([gem redis-store](https://github.com/redis-store/redis-store)) ([redis storage](https://redis.io/))
- `Dalli::Client` ([gem dalli](https://github.com/petergoldstein/dalli)) ([memcached storage](https://memcached.org/))
- `ActiveSupport::Cache::RedisCacheStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/redis_cache_store.rb)) ([redis cache storage](https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html))
- `ActiveSupport::Cache::MemCacheStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/mem_cache_store.rb)) ([memcache storage](https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html))
- `ActiveSupport::Cache::FileStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/file_store.rb)) ([file storage](https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html))
- `ActiveSupport::Cache::MemoryStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/memory_store.rb)) ([in memory storage](https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html))

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
        - [AnyCache with ActiveSupport::Cache::MemCacheStore](#anycache-with-activesupportcachememcachestore)
        - [AnyCache with ActiveSupport::Cache::FileStore](#anycache-with-activesupportcachefilestore)
        - [AnyCache with ActiveSupport::Cache::MemoryStore](#anycache-with-activesupportcachememorystore)
    - [Many cache storages](#many-cache-storages)
    - [Custom cache clients](#custom-cache-clients)
- [Operations](#operations)
    - [Read](#read)
    - [Write](#write)
    - [Delete](#delete)
    - [Increment](#increment)
    - [Decrement](#decrement)
    - [Expire](#expire)
    - [Persist](#persist)
    - [Clear](#clear)

---

### Creation

To instantiate AnyCache instance you have to provide a client.
Client - an independent driver that works with a corresponding cache storage (external dependency).

Supported clients:

- `Redis`
- `Redis::Store`
- `Dalli::Client`
- `ActiveSupport::Cache::RedisCacheStore`
- `ActiveSupport::Cache::MemCacheStore`
- `ActiveSupport::Cache::FileStore`
- `ActiveSupport::Cache::MemoryStore`

`AnyCache` can be instantiated by two ways:

- with explicit client object instantiated manually;
- via configuration;

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
# --- or ---
client = ActiveSupport::Cache::MemCacheStore.new(...)
# -- or --
client = ActiveSupport::Cache::FileStore.new(...)
# -- or --
client = ActiveSupport::Cache::MemoryStore.new(...)

# 2) build AnyCache instance
any_cache = AnyCache.build(client) # => <AnyCache:0x00007f990527f268 ...>
```

#### Config-based creation

You can configure `AnyCache` globally or create subclasses and configure each of them. After that
storage instantiation works via `.build` method without explicit attributes.

- `AnyCache.configure` is used for configuration;
- `config.driver` is used for determine which client should be used;
- `config.__driver_name__.options` stores client-related options;

Supported drivers:

- `:redis` - [Redis](#anycache-with-redis);
- `:redis_tore` - [Redis::Client](#anycache-with-redisstore);
- `:dalli` - [Dalli::Client](#anycache-with-dalliclient);
- `:as_redis_cache_store` - [ActiveSupport::Cache::RedisCacheStore](#anycache-with-activesupportcacherediscachestore);
- `:as_mem_cache_store` - [ActiveSupport::Cache::MemCacheStore](#anycache-with-activesupportcachememcachestore);
- `:as_file_store` - [ActiveSupport::Cache::FileStore](#anycache-with-activesupportcachefilestore);
- `:as_memory_store` - [ActiveSupport::Cache::MemoryStore](#anycache-with-activesupportcachememorystore);

##### `AnyCache` with `Redis`:

```ruby
AnyCache.configure do |conf|
  conf.driver = :redis
  conf.redis.options = { ... } # Redis-related options
end

AnyCache.build
```

##### `AnyCache` with `Redis::Store`:

```ruby
AnyCache.configure do |conf|
  conf.driver = :redis_store
  conf.redis_store.options = { ... } # Redis::Store-related options
end

AnyCache.build
```

##### `AnyCache` with `Dalli::Client`:

```ruby
AnyCache.configure do |conf|
  conf.driver = :dalli
  conf.dalli.servers = ... # string or array of strings
  conf.dalli.options = { ... } # Dalli::Client-related options
end

AnyCache.build
```

##### `AnyCache` with `ActiveSupport::Cache::RedisCacheStore`:

```ruby
AnyCache.configure do |conf|
  conf.driver = :as_redis_cache_store
  conf.as_redis_cache_store.options = { ... } # ActiveSupport::Cache::RedisCacheStore-related options
end

AnyCache.build
```

##### `AnyCache` with `ActiveSupport::Cache::MemCacheStore`:

```ruby
AnyCache.configure do |conf|
  conf.driver = :as_mem_cache_store
  conf.as_memory_store.servers = ... # string or array of strings
  conf.as_memory_store.options = { ... } # ActiveSupport::Cache::MemCacheStore-related options
end

AnyCache.build
```

##### `AnyCache` with `ActiveSupport::Cache::FileStore`:

```ruby
AnyCache.configure do |conf|
  conf.driver = :as_file_store
  conf.as_file_store.cache_path = '/path/to/cache'
  conf.as_file_store.options = { ... } # ActiveSupport::Cache::FileStore-related options
end

AnyCache.build
```

##### `AnyCache` with `ActiveSupport::Cache::MemoryStore`:

```ruby
AnyCache.configure do |conf|
  conf.driver = :as_memory_store
  conf.as_memory_store.options = { ... } # ActiveSupport::Cache::MemoryStore-related options
end

AnyCache.build
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

- `#read(key, [**options])` ([doc](#read))
- `#write(key, value, [**options])` ([doc](#write))
- `#delete(key, [**options])` ([doc](#delete))
- `#increment(key, amount, [**options])` ([doc](#increment))
- `#decrmeent(key, amount, [**options])` ([doc](#decrement))
- `#expire(key, [**options])` ([doc](#expire))
- `#persist(key, [**options])` ([doc](#persist))
- `#clear([**options])` ([doc](#clear))

```ruby
class MyCacheClient
  # ...

  def read
    # ...
  end

  def write
    # ...
  end

  # ...
end

AnyCache.build(MyCacheClient.new)
```

## Operations

`AnyCache` provides a following operation set:

- [read](#read)
- [write](#write)
- [delete](#delete)
- [increment](#increment)
- [decrement](#decrement)
- [expire](#expire)
- [persist](#persist)
- [clear](#clear)

---

### Read

- `AnyCache#read(key)` - get entry value from cache storage

```ruby
# --- entry exists ---
any_cache.read("data") # => "some_data"

# --- entry doesnt exist ---
any_cache.read("data") # => nil
```

---

### Write

- `AnyCache#write(key, value, [expires_in:])` - write new entry to cache storage

```ruby
# --- permanent entry ---
any_cache.write("data", 123)

# --- temporal entry (expires in 60 seconds) ---
any_cache.write("data", 123, expires_in: 60)
```

---

### Delete

- `AnyCache#delete(key)` - remove entry from cache storage

```ruby
any_cache.delete("data")
```

---

### Increment

- `AnyCache#increment(key, amount = 1, [expires_in:])` - increment entry's value by passed amount
  and set new expiration time if needed

```ruby
# --- increment existing entry ---
any_cache.write("data", 1)

# --- increment by default value (1) ---
any_cache.increment("data") # => 2

# --- increment by custom value ---
any_cache.increment("data", 12) # => 14

# --- increment and expire after 31 seconds
any_cache.incrmeent("data", expires_in: 31) # => 15

# --- increment nonexistent entry (create new entry) ---
any_cache.increment("another_data", 5, expires_in: 5) # => 5
```

---

### Decrement

- `AnyCache#decrement(key, amount = 1, [expires_in:])` - decrement entry's value by passed amount
  and set new expiration time if needed

```ruby
# --- decrement existing entry ---
any_cache.write("data", 15)

# --- decrement by default value (1) ---
any_cache.decrement("data") # => 14

# --- decrement by custom value ---
any_cache.decrement("data", 10) # => 4

# --- decrement and expire after 5 seconds
any_cache.decrememnt("data", expirs_in: 5) # => 3

# --- decrement nonexistent entry (create new entry) ---
any_cache.decrememnt("another_data", 2, expires_in: 10) # => -2 (or 0 for Dalli::Client)
```

---

### Expire

- `AnyCache#expire(key, [expires_in:])` - expire entry immediately or set the new expiration time

```ruby
# --- expire immediately ---
any_cache.expire("data")

# --- set new expiration time (in seconds) --
any_cache.expire("data", expires_in: 36)
```

---

### Persist

- `AnyCache#persist(key)` - change entry's expiration time to permanent

```ruby
# --- create temporal entry (30 seconds) ---
any_cache.write("data", { a: 1 }, expires_in: 30)

# --- remove entry expiration (make it permanent) ---
any_cache.persist("data")
```

---

### Clear

- `AnyCache#clear()` - clear cache database

```ruby
# --- prepare cache data ---
any_cache.write("data", { a: 1, b: 2 })
any_cache.write("another_data", 123_456)

any_cache.read("data") # => { a: 1, b: 2 }
any_cache.read("another_data") # => 123_456

# --- clear cache ---
any_cache.clear

any_cache.read("data") # => nil
any_cache.read("another_data") # => nil
```

---

## Build

- see [bin/rspec](bin/rspec)

```shell
bin/rspec --test-redis # run specs with Redis
bin/rspec --test-redis-store # run specs with Redis::Store
bin/rspec --test-dalli # run specs with Dalli::Client
bin/rspec --test-as-file-store # run specs with ActiveSupport::Cache::FileStore
bin/rspec --test-as-memory-store # run specs with ActiveSupport::Cache::MemoryStore
bin/rspec --test-as-redis-cache-store # run specs with ActiveSupport::Cache::RedisCacheStore
bin/rspec --test-as-mem-cache-store # run specs with ActiveSupport::Cache::MemCacheStore
```

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
