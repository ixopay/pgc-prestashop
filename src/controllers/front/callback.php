<?php
/**
 */

class PaymentGatewayCloudCallbackModuleFrontController extends ModuleFrontController
{
    public function postProcess()
    {
        $cartId = Tools::getValue('id_cart');
        $prefix = strtoupper(Tools::getValue('type', ''));
        $notification = Tools::file_get_contents('php://input');

        \PaymentGatewayCloud\Client\Client::setApiUrl(Configuration::get('PAYMENT_GATEWAY_CLOUD_HOST', null));
        $client = new \PaymentGatewayCloud\Client\Client(
            Configuration::get('PAYMENT_GATEWAY_CLOUD_' . $prefix . '_ACCOUNT_USER', null),
            Configuration::get('PAYMENT_GATEWAY_CLOUD_' . $prefix . '_ACCOUNT_PASSWORD', null),
            Configuration::get('PAYMENT_GATEWAY_CLOUD_' . $prefix . '_API_KEY', null),
            Configuration::get('PAYMENT_GATEWAY_CLOUD_' . $prefix . '_SHARED_SECRET', null)
        );

        if (empty($_SERVER['HTTP_DATE']) ||
            empty($_SERVER['HTTP_AUTHORIZATION']) ||
            $client->validateCallback($notification, $_SERVER['QUERY_STRING'], $_SERVER['HTTP_DATE'], $_SERVER['HTTP_AUTHORIZATION'])
        ) {
            die('invalid callback');
        }

        $orderId = Tools::getValue('id_order');
        $order = new Order($orderId);

        $callback = $client->readCallback($notification);

        if ($callback->getResult() === 'OK') {
            $this->processSuccess($cartId, $order, $callback);
            die('OK');
        }

        $this->processFailure($cartId, $order, $callback);
        die('OK');
    }

    /**
     * @param string $cartId
     * @param Order $order
     * @param \PaymentGatewayCloud\Client\Callback\Result $callback
     * @throws PrestaShopException
     */
    private function processSuccess($cartId, $order, $callback)
    {
        switch ($callback->getTransactionType()) {
            case 'DEBIT':
            case 'CAPTURE':
                $this->updateOrderPayments($order, $callback, _PS_OS_PAYMENT_);
                break;
            case 'PREAUTHORIZE':
                $this->updateOrderPayments($order, $callback, _PS_OS_PREPARATION_);
                break;
            case 'VOID':
                $order->setCurrentState(_PS_OS_CANCELED_);
                $orderPayments = OrderPayment::getByOrderReference($order->reference);
                $orderPayments[0]->amount = 0;
                break;
            case 'CHARGEBACK':
            case 'CREDIT':
                $order->setCurrentState(_PS_OS_REFUND_);
                $orderPayments = OrderPayment::getByOrderReference($order->reference);
                // manually triggering repeated callbacks would desync this...
                $orderPayments[0]->amount -= $callback->getAmount();
                $orderPayments[0]->save();
                break;

            case 'CHARGEBACK-REVERSAL':
                // TODO
                break;
        }
    }

    /**
     * @param string $cartId
     * @param Order $order
     * @param \PaymentGatewayCloud\Client\Callback\Result $callback
     */
    private function processFailure($cartId, $order, $callback)
    {
        $orderId = Order::getIdByCartId((int)($cartId));
        $order = new Order($orderId);

        $order->setCurrentState(_PS_OS_ERROR_);

//        $orderPayments = OrderPayment::getByOrderReference($order->reference);
//        if (!empty($orderPayments)) {
//            $orderPayments[0]->transaction_id = $callback->getPurchaseId();
//            $orderPayments[0]->save();
//        }
    }

    /**
     * @param Order $order
     * @param \PaymentGatewayCloud\Client\Callback\Result $callback
     * @param string $orderState
     * @throws PrestaShopException
     */
    private function updateOrderPayments($order, $callback, $orderState)
    {
        $order->setCurrentState($orderState);

        $orderPayments = OrderPayment::getByOrderReference($order->reference);

        /** @var OrderPayment $orderPayment */
        $orderPayment = $orderPayments[0];
        $orderPayment->transaction_id = $callback->getPurchaseId();

        $returnData = $callback->getReturnData() ;
        if ($returnData instanceof \PaymentGatewayCloud\Client\Data\Result\CreditcardData) {
            $orderPayment->payment_method = strtoupper($returnData->getType());
            $orderPayment->card_brand = $returnData->getBinBrand();
            $orderPayment->card_number = $returnData->getFirstSixDigits() . ' ... ' . $returnData->getLastFourDigits();
            $orderPayment->card_expiration = $returnData->getExpiryMonth() . '/' . $returnData->getExpiryYear();
            $orderPayment->card_holder = $returnData->getCardHolder();
        }

        $orderPayment->save();
    }
}
