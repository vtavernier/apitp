Rails.application.configure do
  # Default e-mail address for mailers
  config.x.apitp.email = ENV['APITP_EMAIL'] || 'apitp@example.com'
end