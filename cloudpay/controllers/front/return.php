<?php
/**
 */

class CloudPayReturnModuleFrontController extends ModuleFrontController
{

    public function postProcess()
    {
        $paymentType = Tools::getValue('type');
        $paymentState = Tools::getValue('state');
        $cartId = Tools::getValue('id_cart');

        if ($paymentState == 'success') {

            $this->processSuccess($cartId);

        } else {
            $orderId = Order::getIdByCartId((int)$cartId);
            $order = new Order($orderId);

            $this->redirectWithNotifications(
                $this->context->link->getPageLink('order', true, $order->id_lang)
            );
        }
    }

    public function processSuccess($cartId)
    {
        sleep(1);
        $orderId = Order::getIdByCartId((int)($cartId));
        $order = new Order($orderId);
        $cartId = $order->id_cart;
        $cart = new Cart((int)($cartId));
        $customer = new Customer($cart->id_customer);

        Tools::redirect('index.php?controller=order-confirmation&id_cart='
            .$cart->id.'&id_module='
            .$this->module->id.'&id_order='
            .$this->module->currentOrder.'&key='
            .$customer->secure_key);

    }

    /**
     * Overwritten translation function, uses the modules translation function with fallback language functionality
     *
     * @param string $key translation key
     * @param string|bool $specific filename of the translation key
     * @param string|null $class not used!
     * @param bool $addslashes not used!
     * @param bool $htmlentities not used!
     *
     * @return string translation
     * @since 1.3.4
     */
    protected function l($key, $specific = false, $class = null, $addslashes = false, $htmlentities = true)
    {
        if (!$specific) {
            $specific = 'return';
        }
        $this->module = Module::getInstanceByName('cloudpay');
        return $this->module->l($key, $specific);
    }
}
