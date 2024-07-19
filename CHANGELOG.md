# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.8.0](https://github.com/maxveldink/sorbet-schema/compare/v0.7.2...v0.8.0) (2024-07-19)


### ⚠ BREAKING CHANGES

* Ensure that nested structs will deeply serialize ([#118](https://github.com/maxveldink/sorbet-schema/issues/118))

### Bug Fixes

* Ensure that nested structs will deeply serialize ([#118](https://github.com/maxveldink/sorbet-schema/issues/118)) ([9216d02](https://github.com/maxveldink/sorbet-schema/commit/9216d028fec806540ec6763ec941e1422eb30357))

## [0.7.2](https://github.com/maxveldink/sorbet-schema/compare/v0.7.1...v0.7.2) (2024-07-11)


### Features

* add coercion support for DateTime ([#116](https://github.com/maxveldink/sorbet-schema/issues/116)) ([6f6c3e1](https://github.com/maxveldink/sorbet-schema/commit/6f6c3e151320455bc9734ebb207f746f2c139393))

## [0.7.1](https://github.com/maxveldink/sorbet-schema/compare/v0.7.0...v0.7.1) (2024-07-09)


### Features

* Add clearer message for CoercionNotSupportedError ([#113](https://github.com/maxveldink/sorbet-schema/issues/113)) ([0eff2f7](https://github.com/maxveldink/sorbet-schema/commit/0eff2f77d0ae3dfb9def11a696afd338df993a54))

## [0.7.0](https://github.com/maxveldink/sorbet-schema/compare/v0.6.0...v0.7.0) (2024-07-08)


### ⚠ BREAKING CHANGES

* Fix mis-serializing hash keys that were suppose to be strings ([#111](https://github.com/maxveldink/sorbet-schema/issues/111))

### Bug Fixes

* Fix mis-serializing hash keys that were suppose to be strings ([#111](https://github.com/maxveldink/sorbet-schema/issues/111)) ([485a6c7](https://github.com/maxveldink/sorbet-schema/commit/485a6c7a83b9e70c731930d8406925304efa04a8))

## [0.6.0](https://github.com/maxveldink/sorbet-schema/compare/v0.5.1...v0.6.0) (2024-07-07)


### ⚠ BREAKING CHANGES

* implement default handling for fields ([#105](https://github.com/maxveldink/sorbet-schema/issues/105))

### Features

* implement default handling for fields ([#105](https://github.com/maxveldink/sorbet-schema/issues/105)) ([054d59f](https://github.com/maxveldink/sorbet-schema/commit/054d59ff92c68b272d495a0816370b9a890f0f50))
* implement SymbolCoercer ([#109](https://github.com/maxveldink/sorbet-schema/issues/109)) ([422a995](https://github.com/maxveldink/sorbet-schema/commit/422a9957177039a3dde5c4daa41d597fd44f2b48))
* implement TypedHashCoercer ([#110](https://github.com/maxveldink/sorbet-schema/issues/110)) ([6d64db7](https://github.com/maxveldink/sorbet-schema/commit/6d64db7fcef8af56cb96f1ee6c42ba1e3ce076c3))
* support T.any for deserialization ([#107](https://github.com/maxveldink/sorbet-schema/issues/107)) ([c0c2ca3](https://github.com/maxveldink/sorbet-schema/commit/c0c2ca369abef136943e633b7987decad7291d98))


### Bug Fixes

* default value set to true causes undefined method [] error ([#108](https://github.com/maxveldink/sorbet-schema/issues/108)) ([6829bbf](https://github.com/maxveldink/sorbet-schema/commit/6829bbf8b6bf47db51209e9874608b7e10c38b8e))

## [0.5.1](https://github.com/maxveldink/sorbet-schema/compare/v0.5.0...v0.5.1) (2024-06-26)


### Features

* support nested structs ([#102](https://github.com/maxveldink/sorbet-schema/issues/102)) ([08428e1](https://github.com/maxveldink/sorbet-schema/commit/08428e18afdbb4121ef2f290e8a85651b2e13edf))

## [0.5.0](https://github.com/maxveldink/sorbet-schema/compare/v0.4.2...v0.5.0) (2024-04-19)


### ⚠ BREAKING CHANGES

* Set minimum Ruby to 3.1 ([#69](https://github.com/maxveldink/sorbet-schema/issues/69))

### Features

* Add schema method to structs ([#60](https://github.com/maxveldink/sorbet-schema/issues/60)) ([4b7ff34](https://github.com/maxveldink/sorbet-schema/commit/4b7ff34bc6a48c42d3ece8d1fad07bdecf0bdc11))


### Miscellaneous Chores

* Set minimum Ruby to 3.1 ([#69](https://github.com/maxveldink/sorbet-schema/issues/69)) ([d2b4ba2](https://github.com/maxveldink/sorbet-schema/commit/d2b4ba2099da24f93a22849e059627221bbda081))

## [0.4.2](https://github.com/maxveldink/sorbet-schema/compare/v0.4.1...v0.4.2) (2024-03-21)


### Features

* Add Schema#add_serializer to easily update serializer ([f665a2a](https://github.com/maxveldink/sorbet-schema/commit/f665a2ab3afbdaa3757c2d9fa489602edbdf8f8f))


### Bug Fixes

* Field equality factors in inline serializer ([8049ddf](https://github.com/maxveldink/sorbet-schema/commit/8049ddf2e1a2af45d6591c2689f2fde60afb5839))

## [0.4.1](https://github.com/maxveldink/sorbet-schema/compare/v0.4.0...v0.4.1) (2024-03-21)


### Features

* Add DateCoercer ([ef8c1db](https://github.com/maxveldink/sorbet-schema/commit/ef8c1dbdf3bd87ab2e64102fbd1434811aa353d8))
* Add inline serializer to fields ([dd8042d](https://github.com/maxveldink/sorbet-schema/commit/dd8042d8d88d67d530c7619ee3cbb108957990d1))

## [0.4.0](https://github.com/maxveldink/sorbet-schema/compare/v0.3.0...v0.4.0) (2024-03-14)


### ⚠ BREAKING CHANGES

* Have coercers take in a type instead of the full field
* Update Field's types to a support Sorbets T::Types::Base classes
* Changed serialize return value to a Result
* adds SerializationError ancestor

### Features

* Add BooleanCoercer ([acd220f](https://github.com/maxveldink/sorbet-schema/commit/acd220f55fe0ebc823de6cc43776a1f510a4acd0))
* Add EnumCoercer ([5c0e2b5](https://github.com/maxveldink/sorbet-schema/commit/5c0e2b51990dfb72218129b0935f881622324194))
* Add from_hash and from_json helpers to Schemas ([#44](https://github.com/maxveldink/sorbet-schema/issues/44)) ([55c2da7](https://github.com/maxveldink/sorbet-schema/commit/55c2da77b7c2636339c684560bf15c51ff3ff4b1))
* Add idempotency to Struct coercer ([3a42957](https://github.com/maxveldink/sorbet-schema/commit/3a42957836afee55b074fc5c8a41eac6d31ada70))
* Add option to serialize values to HashSerializer ([710d365](https://github.com/maxveldink/sorbet-schema/commit/710d365d477bd6c6bff20929fcdcc1d1cc95bdb3))
* Adds TypedArray coercer ([795ddd9](https://github.com/maxveldink/sorbet-schema/commit/795ddd97f05502b154d4cb165878c1f78935cb3c))


### Code Refactoring

* adds SerializationError ancestor ([f8ea753](https://github.com/maxveldink/sorbet-schema/commit/f8ea75304613cbab17f698006698a2524a44b538))
* Changed serialize return value to a Result ([948c678](https://github.com/maxveldink/sorbet-schema/commit/948c67815dab19793dd2f321a90797d123740e0e))
* Have coercers take in a type instead of the full field ([c06169e](https://github.com/maxveldink/sorbet-schema/commit/c06169e0fa1cf7c8f645ecabef19cc2f5facffe4))
* Update Field's types to a support Sorbets T::Types::Base classes ([9ef1cd5](https://github.com/maxveldink/sorbet-schema/commit/9ef1cd5caf09396d8dae6a4db1feeb4f88dd25e9))

## [0.3.0](https://github.com/maxveldink/sorbet-schema/compare/v0.2.2...v0.3.0) (2024-03-12)


### ⚠ BREAKING CHANGES

* Remove struct_ext for now

### Code Refactoring

* Remove struct_ext for now ([4a505cb](https://github.com/maxveldink/sorbet-schema/commit/4a505cba47b7fd0ae96d76a543f97228a3cd00d7))

## [0.2.2](https://github.com/maxveldink/sorbet-schema/compare/v0.2.1...v0.2.2) (2024-03-12)


### Bug Fixes

* Add unused options parameter to  on s ([#40](https://github.com/maxveldink/sorbet-schema/issues/40)) ([f5f8a05](https://github.com/maxveldink/sorbet-schema/commit/f5f8a05c05c2c5959b2f733f4289ddc807075c4d))

## [0.2.1](https://github.com/maxveldink/sorbet-schema/compare/v0.2.0...v0.2.1) (2024-03-11)


### Bug Fixes

* Add options argument for use by ActiveSupport serialization ([#37](https://github.com/maxveldink/sorbet-schema/issues/37)) ([4326c00](https://github.com/maxveldink/sorbet-schema/commit/4326c00d20e4f16de1c4a0562725b403fea92afd))

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
