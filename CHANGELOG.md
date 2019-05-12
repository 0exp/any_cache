# Changelog
All notable changes to this project will be documented in this file.

## [0.5.0] - 2019-05-12
### Added
- Introduce Plugin Ecosystem (`AnyCache::Plugins`):
  - load plugin: `AnyCache.plugin('plugin_name')` or `AnyCache.plugin(:plugin_name)`;
  - get registered plugins: `AnyCache.plugins #=> array of strings`
- Support for last ruby versions (`ruby@2.6.3`, `ruby@2.4.6`, `ruby@2.5.5`)

### Changed
- Actualized dependencies (`qonfig` - `~> 0.10`);
- Actualized development dependencies;

## [0.4.0] - 2018-12-04
- `AnyCache#cleanup` - remove expired entries manually
  (make sence only for `:as_file_store` and `:as_memory_store` at this moment);
- automatic object marshaling (used in `fetch`, `fetch_multi`, `write`, `write_multi`, `read`, `read_multi`):
  - used by default (`raw: false`);
  - can be disabled via `raw: true` option;
  - `raw: true` is required for incrementable/decrementable entries;

## [0.3.1] - 2018-10-08
### Added
- patch interface `AnyCache.enable_patch!(:patch_series_name)`:
  - `ActiveSupport::Cache::DalliStore` patch: now the `#fetch` method provides
    a cache key attribute to the fallback proc (can be enabled via `.enable(:dalli_store)`);

## [0.3.0] - 2018-10-06
### Added
- support for `ActiveSupport::Cache::DalliStore` client;
- multi-operations: `#read_multi`, `#write_multi`, `#fetch_multi`, `#delete_matched`;
- logging:
  - configuration: `AnyCache.configure { |conf| conf.logger = your_logger_object }`;
  - disable logging: `AnyCache.configure { |conf| conf.logger = nil }`;
  - `::Logger.new(STDOUT)` with `::Logger::INFO` level is used by default (an instance of `AnyCache::Logging::Logger`);
  - log message contains the following information:
    - standard log data (level and time);
    - cache class name;
    - current cache operation (`read`, `write` and etc);
    - cache operation arguments;

## [0.2.0] - 2018-09-03
### Added
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
