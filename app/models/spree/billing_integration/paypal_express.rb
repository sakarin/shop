class Spree::BillingIntegration::PaypalExpress < Spree::BillingIntegration
  preference :login, :string
  preference :password, :string
  preference :signature, :string
  preference :review, :boolean, :default => false
  preference :no_shipping, :boolean, :default => false
  preference :currency, :string, :default => 'GBP'

  preference :fake_domain, :string

  attr_accessible :preferred_login, :preferred_password, :preferred_signature, :preferred_review, :preferred_no_shipping
  attr_accessible :preferred_currency, :preferred_allow_guest_checkout, :preferred_server, :preferred_test_mode, :preferred_fake_domain


  def provider_class
    ActiveMerchant::Billing::PaypalExpressGateway
  end

end
