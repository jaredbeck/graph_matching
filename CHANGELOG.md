# Change Log

This project follows [semver 2.0.0][1] and the recommendations
of [keepachangelog.com][2].

## 0.2.1 (2020-02-10)

### Fixed

- [#10](https://github.com/jaredbeck/graph_matching/pull/10) -
   `WeightedBigraph#maximum_weighted_matching` hangs forever

## 0.2.0 (2019-02-15)

### Breaking Changes

- Drop support for ruby < 2.3
- Removed `GraphMatching::VERSION`, use `GraphMatching.gem_version` instead

### Fixed

- [#7](https://github.com/jaredbeck/graph_matching/pull/7) -
  An edge can be any `Numeric`

## 0.1.1 (2017-05-10)

### Fixed

- Reduce size of gem from 9 MB to 32 kb by omitting unnecessary files

## 0.1.0 (2017-05-10)

### Breaking Changes

- Drop support for EOL rubies (< 2.2)

## 0.0.2 (2016-08-15)

### Breaking Changes

- Drop support for ruby 1.9.3.

### Added

None

### Fixed

None

## 0.0.1 (2015-03-23)

Initial release.  All four algorithms have been implemented, but the API is still in flux.
Also, additional input validations will probably be added.

[1]: http://semver.org/spec/v2.0.0.html
[2]: http://keepachangelog.com/
