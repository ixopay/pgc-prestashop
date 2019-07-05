
<form id="payment-form" data-id="{$id}" method="POST" action="{$action}">
<input type="hidden" name="ccEmail" value="">
<div>
    <div id="payment-error-{$id}" class="alert alert-warning" style="display: none;">
        ich bin ein error
    </div>
    <div class="row">
        <div class="form-group col-md-6">
            <label class="form-control-label">Firstname</label>
            <div class="">
                <input type="text" class="form-control" name="ccFirstName" id="cloudpay-ccFirstName-{$id}" />
            </div>
        </div>
        <div class="form-group col-md-6">
            <label class="form-control-label">Lastname</label>
            <div class="">
                <input type="text" class="form-control" name="ccLastName" id="cloudpay-ccLastName-{$id}" />
            </div>
        </div>
    </div>

    <div class="row">
        <div class="form-group col-md-8">
            <label class="form-control-label">Card Number</label>
            <div class="">
                <div id="cloudpay-ccCardNumber-{$id}" style="height: 45px; margin-left: -3px; margin-top: -3px;"></div>
            </div>
        </div>
        <div class="form-group col-md-4">
            <label class="form-control-label">CVV</label>
            <div class="">
                <div id="cloudpay-ccCvv-{$id}" style="height: 45px; margin-left: -3px; margin-top: -3px;"></div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="form-group col-md-2">
            <label class="form-control-label">Month</label>
            <div class="">
                <select class="form-control" name="ccExpiryMonth" id="cloudpay-ccExpiryMonth-{$id}">
                    {foreach from=$months item=month}
                        <option value="{$month}">{$month}</option>
                    {/foreach}
                </select>
            </div>
        </div>
        <div class="form-group col-md-3">
            <label class="form-control-label">Year</label>
            <div class="">
                <select class="form-control" name="ccExpiryYear" id="cloudpay-ccExpiryYear-{$id}">
                    {foreach from=$years item=year}
                        <option value="{$year}">{$year}</option>
                    {/foreach}
                </select>
            </div>
        </div>
    </div>
</div>
</form>

{literal}
<script type="text/javascript">
    var id = '{/literal}{$id}{literal}';

    var payment = new PaymentJs("1.2");
    payment.init({/literal}'{$integrationKey}', 'cloudpay-ccCardNumber-{$id}', 'cloudpay-ccCvv-{$id}'{literal}, function(payment) {
        var style = {
            'background': '#f1f1f1',
            'color': '#7a7a7a',
            'border': '1px solid rgba(0,0,0,.25)',
            'outline': 'none',

            'margin': '3px',
            'padding': '.5rem 1rem',
            'font-size': '1rem',
            'width': 'calc(100% - 6px)',
        };
        var focusStyle = {
            'background-color': '#fff',
            'color': '#232323',
            'border': '1px solid #66afe9',
            'outline': '.1875rem solid #2fb5d2',

            'margin': '3px',
            'padding': '.5rem 1rem',
            'font-size': '1rem',
            'width': 'calc(100% - 6px)',
        };

        payment.setNumberStyle(style);
        payment.setCvvStyle(style);

        // Focus events
        payment.numberOn('focus', function() {
            payment.setNumberStyle(focusStyle);
        });
        payment.cvvOn('focus', function() {
            payment.setCvvStyle(focusStyle);
        });
        // Blur events
        payment.numberOn('blur', function() {
            payment.setNumberStyle(style);
        });
        payment.cvvOn('blur', function() {
            payment.setCvvStyle(style);
        });
    });

    window.cloudpayPayment[id] = payment;
</script>
{/literal}
