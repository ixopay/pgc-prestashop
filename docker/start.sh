#!/bin/bash
# set -x
set -euo pipefail

echo -e "Starting Prestashop"

/app-entrypoint.sh nami start --foreground apache &

if [ ! -f "/setup_complete" ]; then

    echo -e "Waiting for Prestashop to Initialize"

    while [ ! -f "/bitnami/prestashop/.initialized" ]; do sleep 2s; done

    while (! $(curl --silent -H "Host: ${PRESTASHOP_HOST}" -L http://localhost:80 | grep "Ecommerce software by PrestaShop" > /dev/null)); do sleep 2s; done

    echo -e "Installing PGC Extension"

    if [ "${BUILD_ARTIFACT}" != "undefined" ]; then
        if [ -f /dist/paymentgatewaycloud.zip ]; then
            echo -e "Using Supplied zip ${BUILD_ARTIFACT}"
            cp /dist/paymentgatewaycloud.zip /paymentgatewaycloud.zip
        else
            echo "Faled to build!, there is no such file: ${BUILD_ARTIFACT}"
            exit 1
        fi
    else
        if [ ! -d "/source/.git" ] && [ ! -f  "/source/.git" ]; then
            echo -e "Checking out branch ${BRANCH} from ${REPOSITORY}"
            git clone $REPOSITORY /tmp/paymentgatewaycloud
            cd /tmp/paymentgatewaycloud
            git checkout $BRANCH
            mv src paymentgatewaycloud
        else
            echo -e "Using Development Source!"
            mkdir -p /tmp/paymentgatewaycloud
            cp -R /source/src/* /tmp/paymentgatewaycloud/
            cd /tmp
        fi
        zip -q -r /paymentgatewaycloud.zip paymentgatewaycloud
    fi
    php /opt/bitnami/prestashop/bin/console prestashop:module install /paymentgatewaycloud.zip
    
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
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_URL',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_HOST';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_CREDITCARD_ENABLED';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_CREDITCARD_ACCOUNT_USER';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_CREDITCARD_ACCOUNT_PASSWORD';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_CREDITCARD_API_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_CREDITCARD_SHARED_SECRET';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_CREDITCARD_INTEGRATION_KEY';"
        mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_CREDITCARD_SEAMLESS';"
        if [ $SHOP_PGC_CC_AMEX ]; then
            echo -e "Enabling Amex PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_AMEX_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_AMEX_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_AMEX_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_AMEX_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_AMEX_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_AMEX_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_AMEX_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_DINERS ]; then
            echo -e "Enabling Diners PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DINERS_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DINERS_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DINERS_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DINERS_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DINERS_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DINERS_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DINERS_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_DISCOVER ]; then
            echo -e "Enabling Discover PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DISCOVER_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DISCOVER_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DISCOVER_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DISCOVER_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DISCOVER_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DISCOVER_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_DISCOVER_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_JCB ]; then
            echo -e "Enabling JCB PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_JCB_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_JCB_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_JCB_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_JCB_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_JCB_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_JCB_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_JCB_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_MAESTRO ]; then
            echo -e "Enabling Maestro PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MAESTRO_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MAESTRO_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MAESTRO_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MAESTRO_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MAESTRO_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MAESTRO_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MAESTRO_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_MASTERCARD ]; then
            echo -e "Enabling Mastercard PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MASTERCARD_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MASTERCARD_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MASTERCARD_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MASTERCARD_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MASTERCARD_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MASTERCARD_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_MASTERCARD_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_UNIONPAY ]; then
            echo -e "Enabling Unionpay PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_UNIONOPAY_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_UNIONOPAY_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_UNIONOPAY_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_UNIONOPAY_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_UNIONOPAY_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_UNIONOPAY_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_UNIONOPAY_SEAMLESS';"
        fi
        if [ $SHOP_PGC_CC_VISA ]; then
            echo -e "Enabling Visa PGC Extension"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '1',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_VISA_ENABLED';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_USER',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_VISA_ACCOUNT_USER';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_PASSWORD',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_VISA_ACCOUNT_PASSWORD';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_API_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_VISA_API_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_SECRET',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_VISA_SHARED_SECRET';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_INTEGRATION_KEY',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_VISA_INTEGRATION_KEY';"
            mysql -u root -h mariadb bitnami_prestashop -B -e "INSERT INTO \`ps_configuration\` SET \`value\` = '$SHOP_PGC_CC_SEAMLESS',\`date_upd\` = NOW(), \`name\` = 'PAYMENT_GATEWAY_CLOUD_VISA_SEAMLESS';"
        fi
    fi

    echo -e "Setup Complete! You can access the instance at: http://${PRESTASHOP_HOST}"

    touch /setup_complete

    if [ $PRECONFIGURE ]; then
        echo -e "Prepare for Pre-Configured build"
        unlink /opt/bitnami/prestashop
        mkdir /opt/bitnami/prestashop
        cp -rf /bitnami/prestashop/.* /opt/bitnami/prestashop/
        cp -rfH /bitnami/prestashop/* /opt/bitnami/prestashop/
        chown -R bitnami:daemon /opt/bitnami/prestashop/
        chmod -R 775 /opt/bitnami/prestashop

        kill 1
    else 
        # Keep script Running
        trap : TERM INT; (while true; do sleep 1m; done) & wait
    fi

else

    if [ ! -d "/bitnami/prestashop" ]; then
        ln -s /opt/bitnami/prestashop /bitnami/prestashop
    fi

    # Keep script Running
    trap : TERM INT; (while true; do sleep 1m; done) & wait

fi
