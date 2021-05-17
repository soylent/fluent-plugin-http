# Change Log
All notable changes to this project will be documented in this file.

## [1.1.0] - 2021-05-17
### Added
- Ruby 3.0 support @mikecarlton

## [1.0.1] - 2020-12-31
### Fixed
- Gemspec

## [1.0.0] - 2018-02-01
### Added
- Support Fluentd v1.0

## [0.6.0] - 2017-11-30
### Added
- Basic authentication

## [0.5.0] - 2017-11-22
### Added
- Configuration option `keep_alive_timeout`

### Fixed
- Skip empty chunks
- Defer opening a new connection

## [0.4.2] - 2017-05-16
### Fixed
- JSON encoding issue

## [0.4.1] - 2017-05-15
### Fixed
- Fix the issue incorrect buffer chunk filenames

## [0.4.0] - 2017-02-08
### Added
- Token access authentication

## [0.3.0] - 2016-12-24
### Changed
- Send a chunk of event records at once

## [0.2.0] - 2016-11-14
### Changed
- Change user agent to `FluentPluginHTTP`

### Added
- Configuration option `accept_status_code`

## [0.1.1] - 2016-11-06
### Fixed
- Include missing `net/http`

## [0.1.0] - 2016-11-05
### Added
- Initial release
