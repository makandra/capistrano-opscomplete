## [1.0.0] - 2021-03-16

### Changed
- Version bump to 1.0 and switch to semantic versioning: There were no breaking changes
- Remove rbenv dependency for our opscomplete infrastructure

## [0.6.7] - 2021-02-05

### Fixed
- Fix missing command in opscomplete:nodejs:check

### Changed
- Improve error message for wrong Node.js version

## [0.6.6] - 2020-12-08

### Fixed
- Fix the error `undefined method 'after' for main:Object (NoMethodError)` when starting the rails application with capistrano-opscomplete required

## [0.6.5] - 2020-11-20

### Fixed
- Correct warning message for `opscomplete:ruby:broken_gems_warning`

## [0.6.4] - 2020-11-19

### Added
- You can now manage the Node.js version which needs to be installed
- Add two new capistrano tasks (`opscomplete:ruby:broken_gems_warning`, `opscomplete:ruby:reset`) which help to mitigate problems when a deployment fails (described in: [#19](https://github.com/makandra/capistrano-opscomplete/issues/19))

### Fixed
- Added missing namespace for code example

## [0.6.3] - 2020-07-23

### Fixed
- regression after ([#18](https://github.com/makandra/capistrano-opscomplete/issues/18)) was merged

## [0.6.2] - 2020-07-23

### Fixed
- rbenv-build changed behaviour of `--list` ([#20](https://github.com/makandra/capistrano-opscomplete/issues/20))

### Changed
- Bumped rack dependency from 2.1.1 to 2.2.3

## [0.6.1] - 2020-04-16
### Added
- Use Ruby 2.6 for development

### Changed
- Add rake as a runtime dependency

## [0.6.0] - 2020-01-13
### Added

- Support for Procfiles/supervisord. See [this makandra card](https://makandracards.com/opscomplete/67829-procfile-support) for more information.

## [0.5.0] - 2019-12-09
### Changed
- Install the bundler version that was used to create the `Gemfile.lock` (`BUNDLED WITH`) if it is present. Can be overwritten by `set :bundler_version`.
- Reword some info output

## [0.4.0] - 2019-09-23
### Added
- ruby-build now honors the :tmp_dir setting

### Changed
- Allow using --force when installing a gem e.g. overwrite binaries
- Quote some shell arguments

## [0.3.0] - 2019-04-05
### Added
- You can now specify the rubygems and bundler version to be installed. (#4)

### Changed
- Support more rubygems versions by using --no-document rather than --no-ri/--no-rdoc (#6)
- Use makandra-rubocop to improve code style, moved some rbenv calls to DSL (#3)
- Fixed a deprecation warning where opscomplete:ruby:update_ruby_build was called multiple times. (#7)

### Removed
- `appserver:restart` task has been obsoleted. Please use https://github.com/capistrano/passenger (#1)

## [0.2.0] - 2018-08-28
### Added
- Look up .ruby-version from your local branch (cwd) if other options fail

### Changed
- Don't use Task#invoke!() to allow support of more capistrano versions (<3.8.2)
- Update documentation to use other capistrano hook, so release_dir is available
- .ruby-version lookup precedence now includes local branch (cwd)
- Fixed a bug where capistrano exits if no ruby version has ever been installed using rbenv
- Less verbose output while updating ruby-build plugin
- If no :rbenv_roles have been provided, default to :all role

## 0.1.0 - 2018-07-11
### Added
- Initial release.

[0.6.0]: https://github.com/makandra/capistrano-opscomplete/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/makandra/capistrano-opscomplete/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/makandra/capistrano-opscomplete/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/makandra/capistrano-opscomplete/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/makandra/capistrano-opscomplete/compare/v0.1.0...v0.2.0
