#!/usr/bin/env bash
set -euo pipefail

error_exit() {
    echo "$1" 1>&2
    exit 1
}

SRC_PATH="/source_code/src"

echo "Linking Source to Extension folder"

ln -s "/source_code/src" "/bitnami/prestashop/modules/paymentgatewaycloud"

echo "Activate Extension"

php /bitnami/prestashop/bin/console prestashop:module install paymentgatewaycloud

