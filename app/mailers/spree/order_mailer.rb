class Spree::OrderMailer < ActionMailer::Base
  helper "spree/base"


  def confirm_email(order, resend=false)

    ActionMailer::Base.smtp_settings = {
        :address   => "smtp.gmail.com",
        :port                 => 587,
        :domain               => "gmail.com",
        :user_name => order.store.mail_username,
        :password => order.store.mail_password,
        :authentication       => "plain",
        :enable_starttls_auto => true
    }

    @order = order
    subject = (resend ? "[RESEND] " : "")
    subject += "#Order Confirmation ##{order.number}"
    mail_params = {:to => order.email, :subject => subject}
    mail_params[:from] = order.store.email if order.store.email.present?
    mail(mail_params)
  end

  def cancel_email(order, resend=false)
    ActionMailer::Base.smtp_settings = {
        :address   => "smtp.gmail.com",
        :port                 => 587,
        :domain               => "gmail.com",
        :user_name => order.store.mail_username,
        :password => order.store.mail_password,
        :authentication       => "plain",
        :enable_starttls_auto => true
    }

    @order = order
    subject = (resend ? "[RESEND] " : "")
    subject += "#Cancellation of Order ##{order.number}"
    mail_params = {:to => order.email, :subject => subject}
    mail_params[:from] = order.store.email if order.store.email.present?
    mail(mail_params)
  end


end
