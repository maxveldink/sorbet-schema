# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0](https://github.com/maxveldink/sorbet-schema/compare/v0.1.1...v0.2.0) (2024-03-08)


### ⚠ BREAKING CHANGES

* Allow for custom Coercers ([#34](https://github.com/maxveldink/sorbet-schema/issues/34))

### Features

* Allow for custom Coercers ([#34](https://github.com/maxveldink/sorbet-schema/issues/34)) ([54c6a53](https://github.com/maxveldink/sorbet-schema/commit/54c6a53019b18d65b18d6d1130c1034f1f6b1341))

## [0.1.1](https://github.com/maxveldink/sorbet-schema/compare/v0.1.0...v0.1.1) (2024-03-08)


### Features

* adds `to_h` and `to_json` methods to Deserialize errors ([#28](https://github.com/maxveldink/sorbet-schema/issues/28)) ([bf5f770](https://github.com/maxveldink/sorbet-schema/commit/bf5f770bc3ca176f18146dd780ad7ccd7fcb05b0))


### Bug Fixes

* Add release-please config ([#30](https://github.com/maxveldink/sorbet-schema/issues/30)) ([b311c28](https://github.com/maxveldink/sorbet-schema/commit/b311c2840d4929776e0133b061e531ae9d1f453f))
* Downgrade release-please action and publish gem through there ([#31](https://github.com/maxveldink/sorbet-schema/issues/31)) ([4ef9881](https://github.com/maxveldink/sorbet-schema/commit/4ef988120c73f42fdfa749d67b5ca0bafc4e52ce))
* update release-please permissions ([#33](https://github.com/maxveldink/sorbet-schema/issues/33)) ([b5d866c](https://github.com/maxveldink/sorbet-schema/commit/b5d866ca304879fc92c8d20ca2b303a3fcdd27c3))

## 0.1.0 (2024-03-05)

### Features

* Add `Integer` and `Float` coercions ([#26](https://github.com/maxveldink/sorbet-schema/issues/26)) ([537f0fc](https://github.com/maxveldink/sorbet-schema/commit/537f0fc4613e95e1e94ac7524488a19afb4018b7))
* add basic JSON serializer and supporting classes ([0c149d1](https://github.com/maxveldink/sorbet-schema/commit/0c149d1cb175630227ad2cd49fcbaf92a2ef22d3))
* Add basic type check without coercion ([#16](https://github.com/maxveldink/sorbet-schema/issues/16)) ([4d987e7](https://github.com/maxveldink/sorbet-schema/commit/4d987e736bea6e4650d6ed6bbf35208c63083322))
* Add Hash and Json conversion methods to `T::Struct` ([#20](https://github.com/maxveldink/sorbet-schema/issues/20)) ([6df87c2](https://github.com/maxveldink/sorbet-schema/commit/6df87c2bb8aa44363c3a02b0fe719725dbe97cb5))
* Create schema extension on `T::Struct` ([#18](https://github.com/maxveldink/sorbet-schema/issues/18)) ([1f335b7](https://github.com/maxveldink/sorbet-schema/commit/1f335b7746199034208df8b5718edae73b4158dd))
* initial repo scaffolding ([479f285](https://github.com/maxveldink/sorbet-schema/commit/479f285c08d952f1e6a9c767488657ba36c603b8))
* Introduce simple HashSerializer ([#19](https://github.com/maxveldink/sorbet-schema/issues/19)) ([80f20a9](https://github.com/maxveldink/sorbet-schema/commit/80f20a9e0164237ceb9743fa5fe062f5a03aba1f))


### Miscellaneous Chores

* release 0.1.0 ([f365058](https://github.com/maxveldink/sorbet-schema/commit/f365058a769a59acb1fd8c505907980a2896c51c))

## [Unreleased]
