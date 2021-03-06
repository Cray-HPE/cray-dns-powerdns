# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.5] - 2022-04-06
### Added
### Changed
- CASMNET-1390 - Update PowerDNS version to 4.4.3 to address CVE-2022-27227
### Deprecated
### Removed
### Fixed
### Security
- CVE-2022-27227 - Incomplete validation of incoming IXFR transfer in Authoritative Server and Recursor

## [0.2.4] - 2022-04-05
### Added
### Changed
- CASMINST-4400 - Switch base container to rolling alpine3 version
### Deprecated
### Removed
### Fixed
### Security

## [0.2.3] - 2022-02-01
### Added
### Changed
- CASMNET-1118 - Alpine BaseOS version update to tackle some CVEs
### Deprecated
### Removed
### Fixed
### Security

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
