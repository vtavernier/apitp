class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound do
      render 'error/not_found', status: 404
    end

    rescue_from Pundit::NotAuthorizedError do
      render 'error/forbidden', status: 403
    end

    rescue_from Exception do |exception|
      ExceptionNotifier::notify_exception(exception, env: request.env, data: { user: current_user })
      render 'error/internal', status: 500
    end
  end

  def zero_downtime_check
    render plain: 'APITP OK', status: 200
  end
end
