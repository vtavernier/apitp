require_relative 'boot'

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module APITP
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib')

    # Load concerns in migrations
    config.autoload_paths << Rails.root.join('db/migrate/concerns')

    # Use local times
    config.time_zone = 'Paris'

    # French
    config.i18n.default_locale = :fr

    # Only PostgreSQL is used, so dump specific schema
    config.active_record.schema_format = :sql

    # Use Que for ActiveJob
    config.active_job.queue_adapter = :que
  end
end
