# Whitelabel PrestaShop Payment Provider Extension

## Requirements

- PHP 7.1+
- [PrestaShop 1.7+ Requirements](http://doc.prestashop.com/display/PS16/System+Administrator+Guide)

## Build

* Clone or download the source from this repository.
* Update [src/logo.png](src/logo.png), [src/logo.gif](src/logo.gif) and images in [src/views/img/creditcard](src/views/img/creditcard).
* Comment/disable adapters in`src/paymentgatewaycloud.php` - see `getCreditCards()` method.
* Run the build script to apply desired branding and create a zip file ready for distribution:
```shell script
php build.php gateway.mypaymentprovider.com "My Payment Provider"
```
- Verify the contents of `build` to make sure they meet desired results.
- Find the newly versioned zip file in the `dist` folder.
- Test by installing the extension in an existing shop installation (see [src/README](src/README.md)).
- Distribute the versioned zip file.

## Provide Updates

- Fetch the updated source from this repository (see [CHANGELOG](CHANGELOG.md)).<br>Note: make sure to not overwrite any previous changes you've made for the previous version, or re-apply these changes.
- Run the build script with the same parameters as the first time:
```shell script
php build.php gateway.mypaymentprovider.com "My Payment Provider"
```
- Find the newly versioned zip file in the `dist` folder.
- Test by updating the extension in an existing shop installation (see [src/README](src/README.md)).
- Distribute the newly versioned zip file.
