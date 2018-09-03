# Changelog
All notable changes to this project will be documented in this file.

## [0.2.0] - 2018-09-03
- fetching operation `AnyCache#fetch(key, force:, expires_in:, &block)`
  - fetches data from the cache using the given key;
  - if a block has been passed and data with the given key does not exist -
    that block will be called and the return value will be written to the cache;
- existence operation `AnyCache#exist?(key)` - determine if an entry exists or not;
- support for `ActiveSupport::Cache::MemCacheStore`;
- configuration layer `AnyCache.configure`: an ability to choose and configure a necessary cache client
  without any explicit client object instantiation (client object will be instantiated implicitly);

## [0.1.0] - 2018-08-26
- Release :)
