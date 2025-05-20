# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2025-05-20
### Added
### Changed
- CASMNET-2322 - Pick up latest cray-postgres in cray-dns-powerdns chart for CSM 1.7
### Deprecated
### Removed
### Fixed
### Security

## [0.4.2] - 2024-09-02
### Added
### Changed
- CASMNET-2244 - Update cray-services version in cray-dns-powerdns chart for CSM 1.6
### Deprecated
### Removed
### Fixed
### Security

## [0.4.1] - 2024-07-16
### Added
### Changed
### Deprecated
### Removed
### Fixed
- CASMMON-415 - Conversion to victoria-metrics broke chart upgrade
### Security

## [0.4.0] - 2024-07-11
### Added
### Changed
- CASMMON-383 - external-dns servicemonitor Victoriametrics
### Deprecated
### Removed
### Fixed
### Security

## [0.3.1] - 2024-02-06
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
- CASMNET-2180 - Upgrade PowerDNS to v4.8.4 and v4.6 is EOL

## [0.3.0] - 2023-03-20
### Added
### Changed
- CASMNET-2079 - Update cray-dns-powerdns to pull in cray-postgresql to maintain postgres support with K8s 1.22
### Deprecated
### Removed
### Fixed
### Security

## [0.2.9] - 2023-03-13
### Added
### Changed
- CASMNET-2078 - Enable DNAME support in PowerDNS
### Deprecated
### Removed
### Fixed
### Security

## [0.2.8] - 2022-12-21
### Added
### Changed
- CASMINST-5441 - Use authentication for csm-helm-charts
### Deprecated
### Removed
### Fixed
### Security

## [0.2.7] - 2022-12-13
### Added
### Changed
- Upgrade cray-service base chart version to 8.2.x
### Deprecated
### Removed
### Fixed
### Security
- CASMNET-1971 - Upgrade PowerDNS to a supported version

## [0.2.6] - 2022-12-07
### Added
### Changed
- CASMNET-1965 - Create Prometheus ServiceMonitor definition to allow collection of PowerDNS metrics
### Deprecated
### Removed
### Fixed
### Security

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
