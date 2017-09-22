class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.x.apitp.email
  layout 'mailer'
end
