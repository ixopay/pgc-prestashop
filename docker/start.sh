#!/bin/bash
set -euo pipefail

fix_symlink() {
    unlink $1
    rm -rf $1
    mkdir $1
    cp -rfLH $2/ $1
    chown -R bitnami:daemon $1
}

error_exit() {
    echo "$1" 1>&2
	exit 1
}

echo -e "Starting Prestashop"

/app-entrypoint.sh nami start --foreground apache &

if [ ! -f "/setup_complete" ]; then

    echo -e "Waiting for Prestashop to Initialize"

    while [ ! -f "/bitnami/prestashop/.initialized" ]; do sleep 2s; done

    while (! $(curl --silent -H "Host: ${PRESTASHOP_HOST}" -L http://localhost:80 | grep "Ecommerce software by PrestaShop" > /dev/null)); do sleep 2s; done

    echo -e "Installing PGC Extension"

    DB_FIELD_NAME="PAYMENT_GATEWAY_CLOUD"
    if [ "${BUILD_ARTIFACT}" != "undefined" ]; then
        if [ -f /dist/paymentgatewaycloud.zip ]; then
            echo -e "Using Supplied zip ${BUILD_ARTIFACT}"
            cp /dist/paymentgatewaycloud.zip /paymentgatewaycloud.zip
        else
            error_exit "Faled to build!, there is no such file: ${BUILD_ARTIFACT}"
        fi
    else
        if [ ! -d "/source/.git" ] && [ ! -f  "/source/.git" ]; then
            echo -e "Checking out branch ${BRANCH} from ${REPOSITORY}"
            git clone $REPOSITORY /tmp/paymentgatewaycloud || error_exit "Faled to clone ${BUILD_ARTIFACT}"
            cd /tmp/paymentgatewaycloud
            git checkout $BRANCH || error_exit "Faled to checkout ${BRANCH}"
        else
            echo -e "Using Development Source!"
            mkdir -p /tmp/paymentgatewaycloud
            cp -R /source/* /tmp/paymentgatewaycloud/
        fi
        cd /tmp/paymentgatewaycloud
        if [ ! -z "${WHITELABEL}" ]; then
            echo -e "Running Whitelabel Script for ${WHITELABEL}"
            echo "y" | php build.php "gateway.mypaymentprovider.com" "${WHITELABEL}" || error_exit "Faled to Run Whitelabel Scriptfor '$WHITELABEL'"
            DEST_FILE="$(echo "y" | php build.php "gateway.mypaymentprovider.com" "${WHITELABEL}" | tail -n 1 | sed 's/.*Created file "\(.*\)".*/\1/g')" || error_exit "Faled to extract Zip File name"
            DB_FIELD_NAME="$(php /whitelabel.php constantCase "${WHITELABEL}")" || error_exit "Failed to extract DB-Field Name"
            cp "${DEST_FILE}" /paymentgatewaycloud.zip
        else
           mv src paymentgatewaycloud
           zip -q -r /paymentgatewaycloud.zip paymentgatewaycloud
        fi
    fi
    php /opt/bitnami/prestashop/bin/console prestashop:module install /paymentgatewaycloud.zip || error_exit "Failed to Install PGC Extension"
    
    if [ $PRECONFIGURE ]; then
        # Enable SSL Everywhere
        mysql -u root -h mariadb bitnami_prestashop -B -e "UPDATE \`ps_configuration\` SET \`value\` = '1', \`date_upd\` = NOW() WHERE \`name\` = 'PS_SSL_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "UPDATE \`ps_configuration\` SET \`value\` = '1', \`date_upd\` = NOW() WHERE \`name\` = 'PS_SSL_ENABLED_EVERYWHERE';"
    else
        # Disable SSL Everywhere
        mysql -u root -h mariadb bitnami_prestashop -B -e "UPDATE \`ps_configuration\` SET \`value\` = '0', \`date_upd\` = NOW() WHERE \`name\` = 'PS_SSL_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "UPDATE \`ps_configuration\` SET \`value\` = '0', \`date_upd\` = NOW() WHERE \`name\` = 'PS_SSL_ENABLED_EVERYWHERE';"
    fi

    echo -e "Configuring Extension"

    # Disable default Payment Providers
    mysql -u root -h mariadb bitnami_prestashop -B -e "DELETE FROM \`ps_module_shop\` WHERE \`id_module\` = 11  AND \`id_shop\` IN(1);"
    mysql -u root -h mariadb bitnami_prestashop -B -e "DELETE FROM \`ps_module_shop\` WHERE \`id_module\` = 30  AND \`id_shop\` IN(1);"

    # Enable PGC Payment Providers
    if [ $SHOP_PGC_URL ]; then
        echo -e "Enabling PGC Extension"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_URL',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_HOST';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_CREDITCARD_SEAMLESS';"
        if [ $SHOP_PGC_CC_AMEX ]; then
            echo -e "Enabling Amex PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_AMEX_SEAMLESS',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_AMEX_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_DINERS ]; then
            echo -e "Enabling Diners PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_DINERS_SEAMLESS',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DINERS_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_DISCOVER ]; then
            echo -e "Enabling Discover PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_DISCOVER_SEAMLESS',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_DISCOVER_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_JCB ]; then
            echo -e "Enabling JCB PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_JCB_SEAMLESS',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_JCB_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_MAESTRO ]; then
            echo -e "Enabling Maestro PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_MAESTRO_SEAMLESS',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MAESTRO_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_MASTERCARD ]; then
            echo -e "Enabling Mastercard PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_MASTERCARD_SEAMLESS',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_MASTERCARD_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_UNIONPAY ]; then
            echo -e "Enabling Unionpay PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONOPAY_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONOPAY_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONOPAY_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONOPAY_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONOPAY_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONOPAY_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_UNIONPAY_SEAMLESS',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_UNIONOPAY_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_VISA ]; then
            echo -e "Enabling Visa PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_VISA_SEAMLESS',\`date_upd\` = NOW(), \`name\` = '${DB_FIELD_NAME}_VISA_SEAMLESS';"
        fi
    fi

    echo -e "Setup Complete! You can access the instance at: http://${PRESTASHOP_HOST}/"

    touch /setup_complete

    if [ $PRECONFIGURE ]; then
        echo -e "Prepare for Pre-Configured build"
        unlink /opt/bitnami/prestashop
        mkdir /opt/bitnami/prestashop
        cp -rf /bitnami/prestashop/.* /opt/bitnami/prestashop/
        cp -rfH /bitnami/prestashop/* /opt/bitnami/prestashop/
        chown -R bitnami:daemon /opt/bitnami/prestashop/
        chmod -R 775 /opt/bitnami/prestashop

        exit 0
    else 
        # Keep script Running
        trap : TERM INT; (while true; do sleep 1m; done) & wait
    fi

else

    # Keep script Running
    trap : TERM INT; (while true; do sleep 1m; done) & wait

fi
