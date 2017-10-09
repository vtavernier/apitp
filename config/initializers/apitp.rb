Rails.application.configure do
  # Default e-mail address for mailers
  config.x.apitp.email = ENV['APITP_EMAIL'] || 'apitp@example.com'

  # Max allowed upload size
  config.x.apitp.max_upload_size = ENV['APITP_MAX_UPLOAD_SIZE'] || (1 * 1024 * 1024)

  # Enable submissions only for people members of a team
  config.x.apitp.team_submissions = ENV['APITP_TEAM_SUBMISSIONS'] || false
end
