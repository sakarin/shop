class Spree::UserPasswordsController < Devise::PasswordsController
  include Spree::Core::ControllerHelpers
  helper 'spree/users', 'spree/base'
  before_filter :set_mail_method, :only =>[:new]

  ssl_required

  after_filter :associate_user

  def new
    if Rails.env.production?
      ActionMailer::Base.default_url_options[:host] = current_store.email
    else
      ActionMailer::Base.default_url_options[:host] = current_store.email.to_s + ":" + request.port.to_s
    end
    super
  end

  # Temporary Override until next Devise release (i.e after v1.3.4)
  # line:
  #   respond_with resource, :location => new_session_path(resource_name)
  # is generating bad url /session/new.user
  #
  # overridden to:
  #   respond_with resource, :location => login_path
  #
  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message(:notice, :send_instructions) if is_navigational_format?
      respond_with resource, :location => spree.login_path
    else
      respond_with_navigational(resource) { render :new }
    end
  end

  def edit
    super
  end

  def update
    super
  end

  private
  def set_mail_method

    ActionMailer::Base.smtp_settings = {
        :address   => "smtp.gmail.com",
        :port                 => 587,
        :domain               => "gmail.com",
        :user_name => current_store.mail_username,
        :password => current_store.mail_password,
        :authentication       => "plain",
        :enable_starttls_auto => true
    }
  end

end
