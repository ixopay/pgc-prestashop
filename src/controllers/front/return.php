<?php
/**
 */

class PaymentGatewayCloudReturnModuleFrontController extends ModuleFrontController
{

    public function postProcess()
    {
        $orderId = Tools::getValue('id_order');
        $order = new Order($orderId);

        $paymentState = Tools::getValue('state');

        if ($paymentState == 'cancel') {

            $params = [
                'submitReorder' => true,
                'id_order' => (int)$order->id,
                'step' => '1',
            ];

            $this->errors[] = $this->module->l('You have canceled your payment.');
            $this->redirectWithNotifications(
                $this->context->link->getPageLink('order', true, $order->id_lang, $params)
            );

        } else if ($paymentState == 'error') {

            $params = [
                'submitReorder' => true,
                'id_order' => (int)$order->id,
                'step' => '5',
            ];

            $this->errors[] = $this->module->l('There was a problem with your payment, please try again or contact the store owner.');
            $this->redirectWithNotifications(
                $this->context->link->getPageLink('order', true, $order->id_lang, $params)
            );
        }
    }
}
