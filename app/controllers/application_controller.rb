class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActionController::InvalidAuthenticityToken do
      respond_to do |format|
        format.html { redirect_to :back, alert: I18n.t('error.invalid_authenticity_token') }
        format.any  { render nothing: true, status: 403 }
      end
    end

    rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError do
      respond_to do |format|
        format.html { render 'error/not_found', status: 404 }
        format.any  { render nothing: true, status: 404 }
      end
    end

    rescue_from Pundit::NotAuthorizedError do
      respond_to do |format|
        format.html { render 'error/forbidden', status: 403 }
        format.any  { render nothing: true, status: 403 }
      end
    end

    rescue_from Exception do |exception|
      ExceptionNotifier::notify_exception(exception, env: request.env, data: { user: current_user })

      respond_to do |format|
        format.html { render 'error/internal', status: 500 }
        format.any  { render nothing: true, status: 500 }
      end
    end
  end

  def zero_downtime_check
    render plain: 'APITP OK', status: 200
  end

  def gpg_key
    key = Rails.configuration.x.apitp.gpg_public_key
    keydata = GPGME::Key.export(key.keyid, armor: true)
    send_data(keydata, filename: "#{Rails.configuration.x.apitp.gpg_private_key.primary_uid.name.parameterize}.asc", type: 'text/plain')
  end
end
