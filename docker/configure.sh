#!/usr/bin/env bash
# set -x
set -euo pipefail

error_exit() {
    echo "$1" 1>&2
    exit 1
}

echo -e "Installing Extension"

echo -e "Checking out branch ${BRANCH} from ${REPOSITORY}"

mkdir /tmp/paymentgatewaycloud
curl -LJ "${REPOSITORY}/tarball/${BRANCH}" | tar -xz --strip-components=1 --directory=/tmp/paymentgatewaycloud
cd /tmp/paymentgatewaycloud

if [ ! -z "${WHITELABEL}" ]; then
    echo -e "Running Whitelabel Script for ${WHITELABEL}"
    echo "y" | php build.php "gateway.mypaymentprovider.com" "${WHITELABEL}" || error_exit "Faled to Run Whitelabel Scriptfor '$WHITELABEL'"
    DEST_FILE="$(echo "y" | php build.php "gateway.mypaymentprovider.com" "${WHITELABEL}" | tail -n 1 | sed 's/.*Created file "\(.*\)".*/\1/g')" || error_exit "Faled to extract Zip File name"
    DB_FIELD_NAME="$(php -r "print strtoupper(str_replace(' ', '_', ucwords(preg_replace('/^a-z0-9]+/', ' ', '${WHITELABEL}'))));")" || error_exit "Failed to extract DB-Field Name"
    php /bitnami/prestashop/bin/console prestashop:module install "${DEST_FILE}" || error_exit "Failed to Install PGC Extension"
else
    ln -s src "/bitnami/prestashop/modules/paymentgatewaycloud"
    php /opt/bitnami/prestashop/bin/console prestashop:module install paymentgatewaycloud || error_exit "Failed to Install PGC Extension"
fi

echo -e "Configuration"

if [ $HTTPS ]; then
    # Enable SSL Everywhere
    mysql -u root -h mariadb bitnami_prestashop -B -e "UPDATE \`ps_configuration\` SET \`value\` = '1', \`date_upd\` = NOW(), \`date_add\` = NOW() WHERE \`name\` = 'PS_SSL_ENABLED';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "UPDATE \`ps_configuration\` SET \`value\` = '1', \`date_upd\` = NOW(), \`date_add\` = NOW() WHERE \`name\` = 'PS_SSL_ENABLED_EVERYWHERE';"
else
    # Disable SSL Everywhere
    mysql -u root -h mariadb bitnami_prestashop -B -e "UPDATE \`ps_configuration\` SET \`value\` = '0', \`date_upd\` = NOW(), \`date_add\` = NOW() WHERE \`name\` = 'PS_SSL_ENABLED';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "UPDATE \`ps_configuration\` SET \`value\` = '0', \`date_upd\` = NOW(), \`date_add\` = NOW() WHERE \`name\` = 'PS_SSL_ENABLED_EVERYWHERE';"
fi

echo -e "Configuring Extension"

# Disable default Payment Providers
mysql -u root -h mariadb bitnami_prestashop -B -e "DELETE FROM \`ps_module_shop\` WHERE \`id_module\` = 11  AND \`id_shop\` IN(1);"
mysql -u root -h mariadb bitnami_prestashop -B -e "DELETE FROM \`ps_module_shop\` WHERE \`id_module\` = 30  AND \`id_shop\` IN(1);"

# Enable PGC Payment Providers
if [ $SHOP_PGC_URL ]; then
    echo -e "Enabling PGC Extension"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_ENABLED';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "DELETE FROM \`ps_configuration\` WHERE \`name\` = '${DB_FIELD_NAME}_HOST';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_URL',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_HOST';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_ENABLED';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_ACCOUNT_USER';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_ACCOUNT_PASSWORD';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_API_KEY';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_SHARED_SECRET';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_INTEGRATION_KEY';"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_SEAMLESS';"
    if [ $SHOP_PGC_CC_AMEX ]; then
        echo -e "Enabling Amex PGC Extension"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_AMEX_SEAMLESS',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_SEAMLESS';"
    fi
    if [ $SHOP_PGC_CC_DINERS ]; then
        echo -e "Enabling Diners PGC Extension"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_DINERS_SEAMLESS',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_SEAMLESS';"
    fi
    if [ $SHOP_PGC_CC_DISCOVER ]; then
        echo -e "Enabling Discover PGC Extension"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_DISCOVER_SEAMLESS',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_SEAMLESS';"
    fi
    if [ $SHOP_PGC_CC_JCB ]; then
        echo -e "Enabling JCB PGC Extension"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_JCB_SEAMLESS',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_SEAMLESS';"
    fi
    if [ $SHOP_PGC_CC_MAESTRO ]; then
        echo -e "Enabling Maestro PGC Extension"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_MAESTRO_SEAMLESS',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_SEAMLESS';"
    fi
    if [ $SHOP_PGC_CC_MASTERCARD ]; then
        echo -e "Enabling Mastercard PGC Extension"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_MASTERCARD_SEAMLESS',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_SEAMLESS';"
    fi
    if [ $SHOP_PGC_CC_UNIONPAY ]; then
        echo -e "Enabling Unionpay PGC Extension"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONPAY_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONPAY_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONPAY_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONPAY_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONPAY_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONPAY_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_UNIONPAY_SEAMLESS',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONPAY_SEAMLESS';"
    fi
    if [ $SHOP_PGC_CC_VISA ]; then
        echo -e "Enabling Visa PGC Extension"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_VISA_SEAMLESS',\`date_upd\` = NOW(), \`date_add\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_SEAMLESS';"
    fi
fi

if [ $DEMO_CUSTOMER_PASSWORD ]; then
    echo -e "Creating Demo Customer"
    # Create Customer
    SECRET=$(cat /bitnami/prestashop/app/config/parameters.php | grep -oP "'cookie_key' => '\K([a-zA-Z0-9]+)")
    DEMO_USER_ID=$(mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_customer\` (id_shop_group, id_shop, id_gender, id_lang, id_risk, firstname, lastname, email, newsletter, optin, active, date_add, date_upd, last_passwd_gen, passwd, secure_key, birthday, is_guest, id_default_group) VALUES (1, 1, 1, 1, 0, 'Robert Z.', 'Johnson', 'RobertZJohnson@einrot.com', 0, 0, 1, NOW(), NOW(), NOW(), MD5('${SECRET}${DEMO_CUSTOMER_PASSWORD}'), 'f1c26d7d47d71ae1e76256f4542146f8', '1991-11-05', 0, 3); SELECT LAST_INSERT_ID();" | tail -n1)

    # Assign Groups
    mysql -u root -h mariadb bitnami_prestashop -B -e "DELETE FROM \`ps_customer_group\` WHERE id_customer = ${DEMO_USER_ID}"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT IGNORE INTO \`ps_customer_group\` (\`id_customer\`, \`id_group\`) VALUES ('${DEMO_USER_ID}', '1')"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT IGNORE INTO \`ps_customer_group\` (\`id_customer\`, \`id_group\`) VALUES ('${DEMO_USER_ID}', '2')"
    mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT IGNORE INTO \`ps_customer_group\` (\`id_customer\`, \`id_group\`) VALUES ('${DEMO_USER_ID}', '3')"

    # Add Address
    DEMO_ADDRESS_ID=$(mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_address\` (id_country, id_state, id_customer, alias, company, lastname, firstname, address1, postcode, city, phone_mobile, date_add, date_upd, active) VALUES (21, 16, ${DEMO_USER_ID}, 'Work', 'Ixolit', 'Johnson', 'Robert Z.', '242 University Hill Road', 62703, 'Springfield', '2175855994', NOW(), NOW(), 1); SELECT LAST_INSERT_ID();" | tail -n1)

    # Add Audit Log Entry
mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_log\` (severity, error_code, message, object_id, id_employee, object_type, date_add, date_upd) VALUES ('1', '0', 'CustomerAddress addition', '${DEMO_ADDRESS_ID}', '1', 'CustomerAddress', NOW(), NOW());"
fi

echo -e "Setup Complete! You can access the instance at: ${PRESTASHOP_HOST}"

