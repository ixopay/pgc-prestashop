FROM bitnami/prestashop:latest

EXPOSE 80

VOLUME /bitnami
VOLUME /source
VOLUME /dist

ENV PRECONFIGURE="" \
    REPOSITORY="https://github.com/user/repo" \
    BRANCH=$DEFAULT_BRANCH \
    SHOP_PGC_URL="sandbox" \
    SHOP_PGC_USER="test-user" \
    SHOP_PGC_PASSWORD="test-pass" \
    SHOP_PGC_API_KEY="test-key" \
    SHOP_PGC_SECRET="secret" \
    SHOP_PGC_INTEGRATION_KEY="int-key" \
    SHOP_PGC_CC_SEAMLESS="0" \
    SHOP_PGC_CC_AMEX="1" \
    SHOP_PGC_CC_DINERS="1" \
    SHOP_PGC_CC_DISCOVER="" \
    SHOP_PGC_CC_JCB="" \
    SHOP_PGC_CC_MAESTRO="" \
    SHOP_PGC_CC_MASTERCARD="" \
    SHOP_PGC_CC_UNIOPNPAY="" \
    SHOP_PGC_CC_VISA="1" \
    SHOP_PGC_CC_AMEX_SEAMLESS="0" \
    SHOP_PGC_CC_DINERS_SEAMLESS="0" \
    SHOP_PGC_CC_DISCOVER_SEAMLESS="0" \
    SHOP_PGC_CC_JCB_SEAMLESS="0" \
    SHOP_PGC_CC_MAESTRO_SEAMLESS="0" \
    SHOP_PGC_CC_MASTERCARD_SEAMLESS="1" \
    SHOP_PGC_CC_UNIOPNPAY_SEAMLESS="1" \
    SHOP_PGC_CC_VISA_SEAMLESS="1"

RUN apt-get update && apt-get install --no-install-recommends -y \
  git \
  zip \
  && apt-get autoclean

COPY start.sh /start.sh

ENTRYPOINT ["/start.sh"]
