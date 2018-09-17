Rails.application.configure do
  # Default e-mail address for mailers
  config.x.apitp.email = ENV['APITP_EMAIL'] || 'apitp@example.com'

  # Max allowed upload size
  config.x.apitp.max_upload_size = (ENV['APITP_MAX_UPLOAD_SIZE'] || (1 * 1024 * 1024).to_s).to_i

  # Enable submissions only for people members of a team
  config.x.apitp.team_submissions = ENV['APITP_TEAM_SUBMISSIONS'] || false

  # Parse GPG key
  gpg_homedir =  Rails.root.join('tmp').join('gpg').to_s
  unless Dir.exist? gpg_homedir
    Dir.mkdir(gpg_homedir)
  end

  GPGME::Engine.set_info(GPGME::PROTOCOL_OpenPGP, GPGME::Engine.info[0].file_name, gpg_homedir)

  config.x.apitp.gpg_private_key = nil
  config.x.apitp.gpg_public_key = nil

  keydata = if ENV['APITP_GPG_KEY'].present? then CGI.unescape(ENV['APITP_GPG_KEY']) end
  key_import = GPGME::Key.import(keydata)
  private_key_fingerprint = key_import.imports.map(&:fingerprint).first

  if private_key_fingerprint
    config.x.apitp.gpg_private_key = GPGME::Key.get(private_key_fingerprint)
    config.x.apitp.gpg_public_key = config.x.apitp.gpg_private_key.primary_subkey
  end
end
