class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.x.apitp.email
  layout 'mailer'

  def gpg_options
    if Rails.configuration.x.apitp.gpg_private_key
      { sign_as: Rails.configuration.x.apitp.gpg_private_key.primary_subkey.keyid }
    else
      { }
    end
  end
end
