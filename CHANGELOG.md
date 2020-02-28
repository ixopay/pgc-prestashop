# Release Notes

## Unreleased
### Fixed
- Refactor front.js and seamless template to allow for multiple cards with seamless integration

## v1.2.2 (2019-12-16)
### Changed
- remove old 1.6 PrestaShop flags
- update order state management
- add success page template
- cleanup
### Fixed
- prevent duplicate orders

## v1.2.1 (2019-09-16)
### Fixed
- Revert "Credit Card" prefix to "CreditCard"

## v1.2.0 (2019-09-10)
### Added
- [README](README.md) note on enabling/disabling additional adapters
### Changed
- Display title, gateway API username & password configurable for individual adapters

## v1.1.0 (2019-09-03)
### Added
- 3D Secure 2.0 extra data
### Fixed
- Potentially invalid global javascript property for payment instance 
- Incorrectly named global javascript variable 

## v1.0.1 (2019-08-30)
### Changed
- Improved build stability

## v1.0.0 (2019-08-29)
### Added
- Build script and [README](README.md) with instructions
- [CHANGELOG](CHANGELOG.md)
### Changed
- Moved renamed source to `src`

## 2019-07-05
### Added
- Module & payment extension
- Credit card payment with redirect flow
- Configuration values for card types
- Seamless integration option
