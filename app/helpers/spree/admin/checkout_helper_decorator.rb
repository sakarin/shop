module Spree
  module Admin
    CheckoutHelper.module_eval do
      def checkout_states
        if @order.payment and @order.payment.payment_method.payment_profiles_supported?
          %w(delivery payment confirm complete)
        else
          %w(delivery payment complete)
        end
      end

    end
  end
end