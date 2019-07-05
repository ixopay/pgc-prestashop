<?php
/**
 */

/**
 * Class CloudPayPaymentModuleFrontController
 *
 * @extends ModuleFrontController
 * @property CloudPay module
 *
 * @since 1.0.0
 */
class CloudPayPaymentModuleFrontController extends ModuleFrontController
{
    public function postProcess()
    {
        $cart = $this->context->cart;
        $cartId = $cart->id;

        if ($cart->id_customer == 0 || $cart->id_address_delivery == 0 || $cart->id_address_invoice == 0 ||
            !$this->module->active
        ) {
            $this->errors = 'An error occured during the checkout process. Please try again.';
            $this->redirectWithNotifications($this->context->link->getPageLink('order'));
        }

        $paymentType = (string) \Tools::getValue('type');
        $prefix = strtoupper($paymentType);

        if (!Configuration::get('CLOUDPAY_'.$prefix.'_ENABLED', null)) {
            die('disabled');
            $this->errors = 'An error occured during the checkout process. Please try again.';
            $this->redirectWithNotifications($this->context->link->getPageLink('order'));
        }

        $this->module->validateOrder(
            $cart->id,
            \Configuration::get(CloudPay::CLOUDPAY_OS_STARTING),
            $cart->getOrderTotal(true),
            $paymentType, // change to nice title
            null,
            [],
            null,
            false,
            $cart->secure_key
        );


        $orderId = $this->module->currentOrder;
        $order = new Order($orderId);

        $amount = round($cart->getOrderTotal(), 2);
        $currency = new Currency($cart->id_currency);

        try {
            \CloudPay\Client\Client::setApiUrl(Configuration::get('CLOUDPAY_HOST', null));
            $client = new \CloudPay\Client\Client(
                Configuration::get('CLOUDPAY_ACCOUNT_USER', null),
                Configuration::get('CLOUDPAY_ACCOUNT_PASSWORD', null),
                Configuration::get('CLOUDPAY_' . $prefix . '_API_KEY', null),
                Configuration::get('CLOUDPAY_' . $prefix . '_SHARED_SECRET', null)
            );

            $debit = new \CloudPay\Client\Transaction\Debit();
            if (Configuration::get('CLOUDPAY_'.$prefix.'_SEAMLESS', null)) {
                $token = (string) \Tools::getValue('token');

                if (empty($token)) {
                    die('empty token');
                    $this->errors = 'An error occured during the checkout process. Please try again.';
                    $this->redirectWithNotifications($this->context->link->getPageLink('order'));
                }

                $debit->setTransactionToken($token);
            }

            $debit->setTransactionId($orderId);
            $debit->setAmount(number_format($amount, 2, '.', ''));
            $debit->setCurrency($currency->iso_code);

            $customerData = $order->getCustomer();

            $customer = new \CloudPay\Client\Data\Customer();
            $customer->setFirstName($customerData->firstname);
            $customer->setLastName($customerData->lastname);
            $customer->setEmail($customerData->email);
            $customer->setIpAddress(\Tools::getRemoteAddr());

            $debit->setCustomer($customer);

            $debit->setSuccessUrl($this->context->link->getModuleLink($this->module->name, 'return', ['id_cart' => $cartId, 'type' => $paymentType, 'state' => 'success'], true));
            $debit->setCancelUrl($this->context->link->getModuleLink($this->module->name, 'return', ['id_cart' => $cartId, 'type' => $paymentType, 'state' => 'cancel'], true));
            $debit->setErrorUrl($this->context->link->getModuleLink($this->module->name, 'return', ['id_cart' => $cartId, 'type' => $paymentType, 'state' => 'error'], true));

            $debit->setCallbackUrl($this->context->link->getModuleLink($this->module->name, 'callback', ['id_cart' => $cartId, 'type' => $paymentType, 'callback' => true], true));

            $paymentResult = $client->debit($debit);
        } catch (\Throwable $e) {
            $this->processFailure($order);
        }
        if ($paymentResult->hasErrors()) {
            $this->processFailure($order);
        }

        if ($paymentResult->isSuccess()) {

            $gatewayReferenceId = $paymentResult->getReferenceId();

            if ($paymentResult->getReturnType() == \CloudPay\Client\Transaction\Result::RETURN_TYPE_ERROR) {
                //error handling
                $errors = $paymentResult->getErrors();

                $this->processFailure($order);

            } elseif ($paymentResult->getReturnType() == \CloudPay\Client\Transaction\Result::RETURN_TYPE_REDIRECT) {

                Tools::redirect($paymentResult->getRedirectUrl());

            } elseif ($paymentResult->getReturnType() == \CloudPay\Client\Transaction\Result::RETURN_TYPE_PENDING) {
                //payment is pending, wait for callback to complete

                //setCartToPending();

            } elseif ($paymentResult->getReturnType() == \CloudPay\Client\Transaction\Result::RETURN_TYPE_FINISHED) {

                $this->module->validateOrder(
                    $cart->id,
                    Configuration::get('PS_OS_PAYMENT'),
                    $cart->getOrderTotal(true),
                    $paymentType, // change to nice title
                    null,
                    [],
                    null,
                    false,
                    $cart->secure_key
                );

                Tools::redirect('index.php?controller=order-confirmation&id_cart='
                    .$cart->id.'&id_module='
                    .$this->module->id.'&id_order='
                    .$this->module->currentOrder.'&key='
                    .$customer->secure_key);
            }
        }
    }

    private function processFailure($order)
    {
        if ($order->current_state == Configuration::get(CloudPay::CLOUDPAY_OS_STARTING)) {
            $order->setCurrentState(_PS_OS_ERROR_);
            $params = [
                'submitReorder' => true,
                'id_order' => (int)$order->id
            ];
            $this->redirectWithNotifications(
                $this->context->link->getPageLink('order', true, $order->id_lang, $params)
            );
        }
    }
}
