<?php

// autoload_static.php @generated by Composer

namespace Composer\Autoload;

class ComposerStaticInit161ab814310b3f198ceaa8c39f4aa87b
{
    public static $prefixLengthsPsr4 = array (
        'P' => 
        array (
            'PaymentGatewayCloud\\Prestashop\\PaymentMethod\\' => 45,
            'PaymentGatewayCloud\\Prestashop\\' => 31,
            'PaymentGatewayCloud\\Client\\' => 27,
        ),
    );

    public static $prefixDirsPsr4 = array (
        'PaymentGatewayCloud\\Prestashop\\PaymentMethod\\' => 
        array (
            0 => __DIR__ . '/../..' . '/payment_method',
        ),
        'PaymentGatewayCloud\\Prestashop\\' => 
        array (
            0 => __DIR__ . '/../..' . '/',
        ),
        'PaymentGatewayCloud\\Client\\' => 
        array (
            0 => __DIR__ . '/../..' . '/client',
        ),
    );

    public static $classMap = array (
        'PaymentGatewayCloud\\Client\\Callback\\ChargebackData' => __DIR__ . '/../..' . '/client/Callback/ChargebackData.php',
        'PaymentGatewayCloud\\Client\\Callback\\ChargebackReversalData' => __DIR__ . '/../..' . '/client/Callback/ChargebackReversalData.php',
        'PaymentGatewayCloud\\Client\\Callback\\Result' => __DIR__ . '/../..' . '/client/Callback/Result.php',
        'PaymentGatewayCloud\\Client\\Client' => __DIR__ . '/../..' . '/client/Client.php',
        'PaymentGatewayCloud\\Client\\CustomerProfile\\CustomerData' => __DIR__ . '/../..' . '/client/CustomerProfile/CustomerData.php',
        'PaymentGatewayCloud\\Client\\CustomerProfile\\DeleteProfileResponse' => __DIR__ . '/../..' . '/client/CustomerProfile/DeleteProfileResponse.php',
        'PaymentGatewayCloud\\Client\\CustomerProfile\\GetProfileResponse' => __DIR__ . '/../..' . '/client/CustomerProfile/GetProfileResponse.php',
        'PaymentGatewayCloud\\Client\\CustomerProfile\\PaymentData\\CardData' => __DIR__ . '/../..' . '/client/CustomerProfile/PaymentData/CardData.php',
        'PaymentGatewayCloud\\Client\\CustomerProfile\\PaymentData\\IbanData' => __DIR__ . '/../..' . '/client/CustomerProfile/PaymentData/IbanData.php',
        'PaymentGatewayCloud\\Client\\CustomerProfile\\PaymentData\\PaymentData' => __DIR__ . '/../..' . '/client/CustomerProfile/PaymentData/PaymentData.php',
        'PaymentGatewayCloud\\Client\\CustomerProfile\\PaymentData\\WalletData' => __DIR__ . '/../..' . '/client/CustomerProfile/PaymentData/WalletData.php',
        'PaymentGatewayCloud\\Client\\CustomerProfile\\PaymentInstrument' => __DIR__ . '/../..' . '/client/CustomerProfile/PaymentInstrument.php',
        'PaymentGatewayCloud\\Client\\CustomerProfile\\UpdateProfileResponse' => __DIR__ . '/../..' . '/client/CustomerProfile/UpdateProfileResponse.php',
        'PaymentGatewayCloud\\Client\\Data\\CreditCardCustomer' => __DIR__ . '/../..' . '/client/Data/CreditCardCustomer.php',
        'PaymentGatewayCloud\\Client\\Data\\Customer' => __DIR__ . '/../..' . '/client/Data/Customer.php',
        'PaymentGatewayCloud\\Client\\Data\\Data' => __DIR__ . '/../..' . '/client/Data/Data.php',
        'PaymentGatewayCloud\\Client\\Data\\IbanCustomer' => __DIR__ . '/../..' . '/client/Data/IbanCustomer.php',
        'PaymentGatewayCloud\\Client\\Data\\Item' => __DIR__ . '/../..' . '/client/Data/Item.php',
        'PaymentGatewayCloud\\Client\\Data\\Request' => __DIR__ . '/../..' . '/client/Data/Request.php',
        'PaymentGatewayCloud\\Client\\Data\\Result\\CreditcardData' => __DIR__ . '/../..' . '/client/Data/Result/CreditcardData.php',
        'PaymentGatewayCloud\\Client\\Data\\Result\\IbanData' => __DIR__ . '/../..' . '/client/Data/Result/IbanData.php',
        'PaymentGatewayCloud\\Client\\Data\\Result\\PhoneData' => __DIR__ . '/../..' . '/client/Data/Result/PhoneData.php',
        'PaymentGatewayCloud\\Client\\Data\\Result\\ResultData' => __DIR__ . '/../..' . '/client/Data/Result/ResultData.php',
        'PaymentGatewayCloud\\Client\\Data\\Result\\WalletData' => __DIR__ . '/../..' . '/client/Data/Result/WalletData.php',
        'PaymentGatewayCloud\\Client\\Exception\\ClientException' => __DIR__ . '/../..' . '/client/Exception/ClientException.php',
        'PaymentGatewayCloud\\Client\\Exception\\InvalidValueException' => __DIR__ . '/../..' . '/client/Exception/InvalidValueException.php',
        'PaymentGatewayCloud\\Client\\Exception\\RateLimitException' => __DIR__ . '/../..' . '/client/Exception/RateLimitException.php',
        'PaymentGatewayCloud\\Client\\Exception\\TimeoutException' => __DIR__ . '/../..' . '/client/Exception/TimeoutException.php',
        'PaymentGatewayCloud\\Client\\Exception\\TypeException' => __DIR__ . '/../..' . '/client/Exception/TypeException.php',
        'PaymentGatewayCloud\\Client\\Http\\ClientInterface' => __DIR__ . '/../..' . '/client/Http/ClientInterface.php',
        'PaymentGatewayCloud\\Client\\Http\\CurlClient' => __DIR__ . '/../..' . '/client/Http/CurlClient.php',
        'PaymentGatewayCloud\\Client\\Http\\CurlExec' => __DIR__ . '/../..' . '/client/Http/CurlExec.php',
        'PaymentGatewayCloud\\Client\\Http\\Exception\\ClientException' => __DIR__ . '/../..' . '/client/Http/Exception/ClientException.php',
        'PaymentGatewayCloud\\Client\\Http\\Exception\\ResponseException' => __DIR__ . '/../..' . '/client/Http/Exception/ResponseException.php',
        'PaymentGatewayCloud\\Client\\Http\\Response' => __DIR__ . '/../..' . '/client/Http/Response.php',
        'PaymentGatewayCloud\\Client\\Http\\ResponseInterface' => __DIR__ . '/../..' . '/client/Http/ResponseInterface.php',
        'PaymentGatewayCloud\\Client\\Json\\DataObject' => __DIR__ . '/../..' . '/client/Json/DataObject.php',
        'PaymentGatewayCloud\\Client\\Json\\ErrorResponse' => __DIR__ . '/../..' . '/client/Json/ErrorResponse.php',
        'PaymentGatewayCloud\\Client\\Json\\ResponseObject' => __DIR__ . '/../..' . '/client/Json/ResponseObject.php',
        'PaymentGatewayCloud\\Client\\Schedule\\ScheduleData' => __DIR__ . '/../..' . '/client/Schedule/ScheduleData.php',
        'PaymentGatewayCloud\\Client\\Schedule\\ScheduleError' => __DIR__ . '/../..' . '/client/Schedule/ScheduleError.php',
        'PaymentGatewayCloud\\Client\\Schedule\\ScheduleResult' => __DIR__ . '/../..' . '/client/Schedule/ScheduleResult.php',
        'PaymentGatewayCloud\\Client\\StatusApi\\StatusRequestData' => __DIR__ . '/../..' . '/client/StatusApi/StatusRequestData.php',
        'PaymentGatewayCloud\\Client\\StatusApi\\StatusResult' => __DIR__ . '/../..' . '/client/StatusApi/StatusResult.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\AbstractTransaction' => __DIR__ . '/../..' . '/client/Transaction/Base/AbstractTransaction.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\AbstractTransactionWithReference' => __DIR__ . '/../..' . '/client/Transaction/Base/AbstractTransactionWithReference.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\AddToCustomerProfileInterface' => __DIR__ . '/../..' . '/client/Transaction/Base/AddToCustomerProfileInterface.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\AddToCustomerProfileTrait' => __DIR__ . '/../..' . '/client/Transaction/Base/AddToCustomerProfileTrait.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\AmountableInterface' => __DIR__ . '/../..' . '/client/Transaction/Base/AmountableInterface.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\AmountableTrait' => __DIR__ . '/../..' . '/client/Transaction/Base/AmountableTrait.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\ItemsInterface' => __DIR__ . '/../..' . '/client/Transaction/Base/ItemsInterface.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\ItemsTrait' => __DIR__ . '/../..' . '/client/Transaction/Base/ItemsTrait.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\OffsiteInterface' => __DIR__ . '/../..' . '/client/Transaction/Base/OffsiteInterface.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\OffsiteTrait' => __DIR__ . '/../..' . '/client/Transaction/Base/OffsiteTrait.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\ScheduleInterface' => __DIR__ . '/../..' . '/client/Transaction/Base/ScheduleInterface.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Base\\ScheduleTrait' => __DIR__ . '/../..' . '/client/Transaction/Base/ScheduleTrait.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Capture' => __DIR__ . '/../..' . '/client/Transaction/Capture.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Debit' => __DIR__ . '/../..' . '/client/Transaction/Debit.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Deregister' => __DIR__ . '/../..' . '/client/Transaction/Deregister.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Error' => __DIR__ . '/../..' . '/client/Transaction/Error.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Payout' => __DIR__ . '/../..' . '/client/Transaction/Payout.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Preauthorize' => __DIR__ . '/../..' . '/client/Transaction/Preauthorize.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Refund' => __DIR__ . '/../..' . '/client/Transaction/Refund.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Register' => __DIR__ . '/../..' . '/client/Transaction/Register.php',
        'PaymentGatewayCloud\\Client\\Transaction\\Result' => __DIR__ . '/../..' . '/client/Transaction/Result.php',
        'PaymentGatewayCloud\\Client\\Transaction\\VoidTransaction' => __DIR__ . '/../..' . '/client/Transaction/VoidTransaction.php',
        'PaymentGatewayCloud\\Client\\Xml\\Generator' => __DIR__ . '/../..' . '/client/Xml/Generator.php',
        'PaymentGatewayCloud\\Client\\Xml\\Parser' => __DIR__ . '/../..' . '/client/Xml/Parser.php',
        'PaymentGatewayCloud\\Prestashop\\PaymentMethod\\CreditCard' => __DIR__ . '/../..' . '/payment_method/CreditCard.php',
        'PaymentGatewayCloud\\Prestashop\\PaymentMethod\\PaymentMethodInterface' => __DIR__ . '/../..' . '/payment_method/PaymentMethodInterface.php',
    );

    public static function getInitializer(ClassLoader $loader)
    {
        return \Closure::bind(function () use ($loader) {
            $loader->prefixLengthsPsr4 = ComposerStaticInit161ab814310b3f198ceaa8c39f4aa87b::$prefixLengthsPsr4;
            $loader->prefixDirsPsr4 = ComposerStaticInit161ab814310b3f198ceaa8c39f4aa87b::$prefixDirsPsr4;
            $loader->classMap = ComposerStaticInit161ab814310b3f198ceaa8c39f4aa87b::$classMap;

        }, null, ClassLoader::class);
    }
}
