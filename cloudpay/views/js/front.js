/**
*/

$(document).ready(
    function () {
        $(document).on('submit', '#payment-form', function (e) {
            console.log('payment form');

            var form = $(this);
            var id = form.attr('data-id');
            if (form.attr('action').search('creditcard') >= 0) {
                placeOrder(e);
            }

            e.preventDefault();

            var data = {
                first_name: form.find('[name=ccFirstName]').val(),
                last_name: form.find('[name=ccLastName]').val(),
                month: form.find('[name=ccExpiryMonth]').val(),
                year: form.find('[name=ccExpiryYear]').val(),
//                email: form.find('[name=ccEmail]').val(),
            };

            let payment = window.cloudpayPayment[id];

            payment.tokenize(
                data,
                (token, cardData) => {
                    form.append('<input type="hidden" name="token" value="'+ token +'"/>');
                    form[0].submit();
                },
                function(errors) {

                    var errorsTexts = [];
                    for (let i=0; i < errors.length; i++) {
                        errorsTexts.push(errors[i].message);
                    }

                    $("#payment-error-" + id).show().html( errorsTexts.join('<br>') );
                    console.log(errors);
                }
            );
        });
    }
);