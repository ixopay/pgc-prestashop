<?php
/**
 */

class CloudPayCallbackModuleFrontController extends ModuleFrontController
{
    public function postProcess()
    {
        $paymentType = Tools::getValue('type');
        $prefix = strtoupper($paymentType);
        $cartId = Tools::getValue('id_cart');

        $notification = Tools::file_get_contents('php://input');

        \CloudPay\Client\Client::setApiUrl(Configuration::get('CLOUDPAY_HOST', null));
        $client = new \CloudPay\Client\Client(
            Configuration::get('CLOUDPAY_ACCOUNT_USER', null),
            Configuration::get('CLOUDPAY_ACCOUNT_PASSWORD', null),
            Configuration::get('CLOUDPAY_' . $prefix . '_API_KEY', null),
            Configuration::get('CLOUDPAY_' . $prefix . '_SHARED_SECRET', null)
        );

        if (empty($_SERVER['HTTP_DATE']) ||
            empty($_SERVER['HTTP_AUTHORIZATION']) ||
            $client->validateCallback($notification, $_SERVER['QUERY_STRING'], $_SERVER['HTTP_DATE'], $_SERVER['HTTP_AUTHORIZATION'])
        ) {
            die('invalid callback');
        }

        $xml = simplexml_load_string($notification);
        $data = json_decode(json_encode($xml),true);

        if ($data['result'] === 'OK') {
            $this->processSuccess($cartId, $data);
        }

        $this->processFailure($cartId, $data);
    }

    private function processSuccess($cartId, $data)
    {
        switch ($data['transactionType']) {
            case 'CHARGEBACK-REVERSAL':
                // TODO
                break;
            case 'CHARGEBACK':
                $orderState = _PS_OS_REFUND_;
                break;
            case 'DEBIT':
                $orderState = _PS_OS_PAYMENT_;
                break;
        }

        $orderId = Order::getIdByCartId((int)($cartId));
        $order = new Order($orderId);
        $order->setCurrentState($orderState);
        $this->changePaymentStatus($order->reference, $data['purchaseId'], $orderState);

        die('OK');
    }

    private function processFailure($cartId, $data)
    {
        $orderId = Order::getIdByCartId((int)($cartId));
        $order = new Order($orderId);

        $order->setCurrentState(_PS_OS_ERROR_);
        $orderPayments = OrderPayment::getByOrderReference($order->reference);
        if (!empty($orderPayments)) {
            $orderPayments[0]->transaction_id = $data['purchaseId'];
            $orderPayments[0]->save();
        }

        die('OK');
    }

    private function changePaymentStatus($reference, $transactionId, $orderState)
    {
        $orderPayments = OrderPayment::getByOrderReference($reference);
        if ($orderState != _PS_OS_CANCELED_&& !empty($orderPayments)) {
            if (count($orderPayments) > 1) {
                $orderPayments[0]->delete();
                $orderPayments[count($orderPayments) - 1]->transaction_id = $transactionId;
                $orderPayments[count($orderPayments) - 1]->save();
            }
        } else {
            $orderPayments[0]->delete();
        }
    }
}
