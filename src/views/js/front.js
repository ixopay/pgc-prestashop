/**
 * seamless form
 */
$('.payment-options .payment-option').on('change', function () {
  setTimeout(function () {
    var $seamlessForm = $('.js-payment-option-form:visible .payment-form-seamless');
    if ($seamlessForm.length) {
      initPaymentGatewayCloutSeamless($seamlessForm[0]);
    }
  }, 10);
});

var initPaymentGatewayCloutSeamless = function (seamlessForm) {
  var validNumber;
  var validCvv;

  var $seamlessForm = $(seamlessForm);
  var integrationKey = $seamlessForm.data('integrationKey');
  var formId = $seamlessForm.data('id');

  var $seamlessCardHolderFirstNameInput = $('#payment-gateway-cloud-ccFirstName-' + formId, $seamlessForm);
  var $seamlessCardHolderLastNameInput = $('#payment-gateway-cloud-ccFirstName-' + formId, $seamlessForm);
  var $seamlessCardNumberInput = $('#payment-gateway-cloud-ccCardNumber-' + formId, $seamlessForm);
  var $seamlessCvvInput = $('#payment-gateway-cloud-ccCvv-' + formId, $seamlessForm);
  var $seamlessExpiryMonthInput = $('#payment-gateway-cloud-ccExpiryMonth-' + formId, $seamlessForm);
  var $seamlessExpiryYearInput = $('#payment-gateway-cloud-ccExpiryYear-' + formId, $seamlessForm);
  var $seamlessError = $('#payment-error-' + formId, $seamlessForm);

  /**
   * fixed seamless input heights
   */
  $seamlessCardNumberInput.css('height', $seamlessCardHolderFirstNameInput.css('height'));
  $seamlessCvvInput.css('height', $seamlessCardHolderFirstNameInput.css('height'));

  /**
   * copy styles
   */
  var style = {
    'background': $seamlessCardHolderFirstNameInput.css('background'),
    'border': 'none',
    'height': '100%',
    'padding': $seamlessCardHolderFirstNameInput.css('padding'),
    'font-size': $seamlessCardHolderFirstNameInput.css('font-size'),
    'color': $seamlessCardHolderFirstNameInput.css('color'),
  };

  /**
   * initialize
   */
  var payment = new PaymentJs('1.2');
  payment.init(integrationKey, $seamlessCardNumberInput.prop('id'), $seamlessCvvInput.prop('id'),
    function (payment) {
      payment.setNumberStyle(style);
      payment.setCvvStyle(style);
      payment.numberOn('input', function (data) {
        validNumber = data.validNumber;
      });
      payment.cvvOn('input', function (data) {
        validCvv = data.validCvv;
      });
    });

  /**
   * handler
   */
  $seamlessForm.submit(function (e) {
    e.preventDefault();

    payment.tokenize(
      {
        first_name: $seamlessCardHolderFirstNameInput.val(),
        last_name: $seamlessCardHolderLastNameInput.val(),
        month: $seamlessExpiryMonthInput.val(),
        year: $seamlessExpiryYearInput.val(),
      },
      function (token, cardData) {
        $seamlessForm.off('submit');
        $seamlessForm.append('<input type="hidden" name="token" value="' + token + '"/>');
        $seamlessForm.submit();
      },
      function (errors) {
        var errorsTexts = [];
        for (let i = 0; i < errors.length; i++) {
          errorsTexts.push(errors[i].message);
        }
        $seamlessError.show().html(errorsTexts.join('<br>'));
      },
    );
  });
};
