FROM bitnami/prestashop:1.7

EXPOSE 80

VOLUME /bitnami
VOLUME /source

ENV ALLOW_EMPTY_PASSWORD="no" \
    BITNAMI_APP_NAME="prestashop" \
    BITNAMI_IMAGE_VERSION="1.7.6-2-debian-9-r8" \
    MARIADB_HOST="mariadb" \
    MARIADB_PORT_NUMBER="3306" \
    MARIADB_ROOT_PASSWORD="" \
    MARIADB_ROOT_USER="root" \
    MYSQL_CLIENT_CREATE_DATABASE_NAME="" \
    MYSQL_CLIENT_CREATE_DATABASE_PASSWORD="" \
    MYSQL_CLIENT_CREATE_DATABASE_PRIVILEGES="ALL" \
    MYSQL_CLIENT_CREATE_DATABASE_USER="" \
    PATH="/opt/bitnami/apache/bin:/opt/bitnami/php/bin:/opt/bitnami/php/sbin:/opt/bitnami/mysql/bin:/opt/bitnami/prestashop/bin:$PATH" \
    PRESTASHOP_COOKIE_CHECK_IP="yes" \
    PRESTASHOP_COUNTRY="us" \
    PRESTASHOP_DATABASE_NAME="bitnami_prestashop" \
    PRESTASHOP_DATABASE_PASSWORD="" \
    PRESTASHOP_DATABASE_USER="bn_prestashop" \
    PRESTASHOP_EMAIL="user@example.com" \
    PRESTASHOP_FIRST_NAME="Bitnami" \
    PRESTASHOP_HOST="localhost" \
    PRESTASHOP_LANGUAGE="en" \
    PRESTASHOP_LAST_NAME="User" \
    PRESTASHOP_PASSWORD="bitnami1" \
    SMTP_HOST="" \
    SMTP_PASSWORD="" \
    SMTP_PORT="" \
    SMTP_PROTOCOL="" \
    SMTP_USER="" \
    PRECONFIGURE="" \
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

RUN apt-get update && apt-get install -y \
  git \
  zip \
  && apt-get autoclean

COPY start.sh /start.sh

ENTRYPOINT ["/start.sh"]
