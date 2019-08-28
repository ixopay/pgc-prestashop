# Whitelabel PrestaShop Payment Provider Extension

## Requirements

- PHP 7.1+
- [PrestaShop 1.7+ Requirements](http://doc.prestashop.com/display/PS16/System+Administrator+Guide)

## Build

- Clone or download the source from this repository.

- Update `src/logo.png`, `src/logo.gif` and images in `src/views/img/creditcard`.

- Run the build script to automatically change white labeled source and create a zip file ready for distribution. 

    $ php build.php "My Payment Provider" gateway.mypaymentprovider.com

- Verify the contents of `build` to make sure they meet desired results.

- Test by installing the built extension zip file in an existing shop installation.

- Distribute the versioned zip file.

## Provide Updates

- Fetch the updated source from this repository (see [Changelog](CHANGELOG.md)).<br>Note: make sure to not overwrite any previous changes you've made for the previous version, or re-apply these changes.

- Run the build script with the same parameters as the first time.

- Distribute the newly versioned zip file. 
