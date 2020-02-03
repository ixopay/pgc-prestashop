**Warning!** This docker image is dedicated for demo usage, we don't recommended to use it in production.

---

# USAGE

To quickly spawn a Prestashop test shop with a plugin tagged at our github.com repository:

```
 REPOSITORY="https://github.com/ixopay/pgc-prestashop" \
 BRANCH="master" \
 PRESTASHOP_HOST="localhost" \
 PRESTASHOP_EMAIL=dev@example.com \
 PRESTASHOP_PASSWORD=dev \
  docker-compose -f docker-compose.github.yml up --build --force-recreate --renew-anon-volumes
```

To develop and test plugin changes, you can run the following docker-compose command from the plugin root directory, to start a Prestashop shop &
initialize a database with a bind mounted version of the plugin. The shop will be accessible via: `http://localhost/administration`.

```
 BITNAMI_IMAGE_VERSION=latest \
 PRESTASHOP_HOST="localhost" \
 PRESTASHOP_EMAIL=dev@example.com \
 PRESTASHOP_PASSWORD=dev \
  docker-compose up --build --force-recreate --renew-anon-volumes
```

By running the command we always run a complete `--build` for the shop container, `--force-recreate` to delete previous containers  and always delete
the previous instance's storage volumes via `--renew-anon-volumes`. We currently use Bitnami Docker images as base for the environment and add our plugin.
Further environment variables can be set, please take a look at `docker/Dockerfile` for a complete list.

## Platform credentials

To successfully test a payment flow you will need merchant credentials for the payment platform and set them via the following environment variables:

```
 SHOP_PGC_URL="https://sandbox.paymentgateway.cloud"
 SHOP_PGC_USER="test-user"
 SHOP_PGC_PASSWORD="test-pass"
 SHOP_PGC_API_KEY="key"
 SHOP_PGC_SECRET="secret"
 SHOP_PGC_INTEGRATION_KEY="int-key"
 SHOP_PGC_CC_SEAMLESS="0"
 SHOP_PGC_CC_AMEX="1"
 SHOP_PGC_CC_DINERS="1"
 SHOP_PGC_CC_DISCOVER=""
 SHOP_PGC_CC_JCB=""
 SHOP_PGC_CC_MAESTRO=""
 SHOP_PGC_CC_MASTERCARD=""
 SHOP_PGC_CC_UNIOPNPAY=""
 SHOP_PGC_CC_VISA="1"
 SHOP_PGC_CC_AMEX_SEAMLESS="0"
 SHOP_PGC_CC_DINERS_SEAMLESS="0"
 SHOP_PGC_CC_DISCOVER_SEAMLESS="0"
 SHOP_PGC_CC_JCB_SEAMLESS="0"
 SHOP_PGC_CC_MAESTRO_SEAMLESS="0"
 SHOP_PGC_CC_MASTERCARD_SEAMLESS="1"
 SHOP_PGC_CC_UNIOPNPAY_SEAMLESS="1"
 SHOP_PGC_CC_VISA_SEAMLESS="1"

```