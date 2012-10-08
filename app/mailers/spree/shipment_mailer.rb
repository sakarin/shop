class Spree::ShipmentMailer < ActionMailer::Base
  helper "spree/base"


  def shipped_email(shipment, resend=false)
    ActionMailer::Base.smtp_settings = {
        :address   => "smtp.gmail.com",
        :port                 => 587,
        :domain               => "gmail.com",
        :user_name => shipment.order.store.mail_username,
        :password => shipment.order.store.mail_password,
        :authentication       => "plain",
        :enable_starttls_auto => true
    }
    @shipment = shipment
    subject = (resend ? "[RESEND] " : "")
    subject += "#Shipment Notification ##{shipment.order.number}"
    mail_params = {:to => shipment.order.email, :subject => subject}
    mail_params[:from] = shipment.order.store.email if shipment.order.store.email.present?
    mail(mail_params)
  end



end
