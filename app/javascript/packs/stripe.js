export class Stripe {
  constructor(signedIn, hasSubscription, i18n, locale) {
    this.signedIn = signedIn;
    this.hasSubscription = hasSubscription;
    this.i18n = i18n;
    this.locale = locale;
  }

  init() {
    if (this.signedIn && this.hasSubscription) {
      $('.btn-checkout').each(function () {
        return this.disableCheckoutButton($(this));
      }.bind(this));

      $(document).on('click', '.btn-checkout', function () {
        return this.disableCheckoutButton($(this));
      }.bind(this));
    } else if (this.signedIn && !this.hasSubscription) {
      $(document).on('click', '.btn-checkout', function () {
        this.redirectToCheckout();
        return false;
      }.bind(this));
    } else {
      $(document).on('click', '.btn-checkout', function () {
        return false;
      });
    }
  }

  redirectToCheckout() {
    var url = '/api/checkout_sessions?locale=' + this.locale; // api_checkout_sessions_path
    $.post(url).done(function (res) {
      var stripe = window.Stripe(process.env.STRIPE_PUBLISHABLE_KEY);
      stripe.redirectToCheckout({sessionId: res.session_id}).then(function (result) {
        alert(result.error.message);
      });
    }).fail(function (xhr) {
      alert(JSON.parse(xhr.responseText).message);
    });
  }

  disableCheckoutButton(button) {
    if (!button.data('checkout-initialized')) {
      button.data('checkout-initialized', true);
      button.attr('disabled', 'disabled');
      button.addClass('disabled');
      button.text(this.i18n['already_purchased']);
    }
    return false;
  }
}
