# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2021-11-30
### Added
### Changed
- CASMNET-859 - Non-root USER for cray-dns-powerdns.
### Deprecated
### Removed
### Fixed
### Security

## [0.2.1] - 2021-11-30
### Added
### Changed
- Update to latest chart-metadata image in order to preserve quotes when rendering YAML and avoid go-yaml compatibility issues with Boolean string values.
### Deprecated
### Removed
### Fixed
### Security

## [0.2.0] - 2021-11-23
### Added
### Changed
- CASMNET-942 - Update image references and new chart build tooling. 
### Deprecated
### Removed
### Fixed
### Security

## [0.1.5] - 2021-11-09
### Added
### Changed
- CASMNET-1016 - Change name of cray-dns-powerdns-can services to cray-dns-powerdns-cmn
- Changed imagePullPolicy to IfNotPresent as Always defeats the purpose of pre-caching.
### Deprecated
### Removed
### Fixed
### Security
