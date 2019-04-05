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

[0.3.0]: https://github.com/makandra/capistrano-opscomplete/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/makandra/capistrano-opscomplete/compare/v0.1.0...v0.2.0
