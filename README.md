# AnyCache &middot; [![Gem Version](https://badge.fury.io/rb/any_cache.svg)](https://badge.fury.io/rb/any_cache) [![Build Status](https://travis-ci.org/0exp/any_cache.svg?branch=master)](https://travis-ci.org/0exp/any_cache) [![Coverage Status](https://coveralls.io/repos/github/0exp/any_cache/badge.svg)](https://coveralls.io/github/0exp/any_cache)

AnyCache - a cache-wrapper that provides the minimalistic generic interface for the all well-known cache storages and includes the minimal set of necessary operations:
`read`, `write`, `delete`, `expire`, `persist`, `clear`, `increment`, `decrement`.

Supported clients:

- `Redis` ([gem redis](https://github.com/redis/redis-rb)) ([redis storage](https://redis.io/))
- `Redis::Store` ([gem redis-store](https://github.com/redis-store/redis-store)) ([redis storage](https://redis.io/))
- `Dalli::Client` ([gem dalli](https://github.com/petergoldstein/dalli)) ([memcached storage](https://memcached.org/))
- `ActiveSupport::Cache::FileStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/file_store.rb)) (file storage)
- `ActiveSupport::Cache::MemoryStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/memory_store.rb)) (in memory storage)
- `ActiveSupport::Cache::RedisCacheStore` ([gem activesupport](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/redis_cache_store.rb)) ([redis storage](https://redis.io/))

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
- **Operations**
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

To instantiate a cache wrapper you have to provide a client.
Client - an independent driver that works with a corresponding cache storage (external dependency).
Supported clients:

- `Redis`
- `Redis::Store`
- `Dalli::Client`
- `ActiveSupport::Cache::RedisCacheStore`
- `ActiveSupport::Cache::FileStore`
- `ActiveSupport::Cache::MemoryStore`

`AnyCache` instantiation:

```ruby
# 1) create a client object
client = Redis.new(...)
# -- or --
client = Redis::Store.new(...)
# -- or --
client = Dalli::Client.new(...)
# -- or --
client = ActiveSupport::Cache::RedisCacheStore.new(...)
# -- or --
client = ActiveSupport::Cache::FileStore.new(...)
# -- or --
client = ActiveSupport::Cache::MemoryStore.new(...)

# 2) build AnyCache instance
any_cache = AnyCache.build(client) # => <AnyCache:0x00007f990527f268 ...>
```

If you want to use your own cache client implementation, you should provide an object that responds to:

- `#read(key, [**options])` ([doc](#read))
- `#write(key, value, [**options])` ([doc](#write))
- `#delete(key, [**options])` ([doc](#delete))
- `#increment(key, amount, [**options])` ([doc](#increment))
- `#decrmeent(key, amount, [**options])` ([doc](#decrement))
- `#expire(key, [**options])` ([doc](#expire))
- `#persist(key, [**options])` ([doc](#persist))
- `#clear([**options])` ([doc](#clear))

---

### Read

- `AnyCache#read(key, [**options])` - get entry value from cache storage

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

- `AnyCache#delete(key, [**options])` - remove entry from cache storage

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

# --- set custom expiration time (in seconds) --
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

- `AnyCache#clear(**options)` - clear cache database

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

## Roadmap

- configuration layer with ability to instantiate cache clients implicitly

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
