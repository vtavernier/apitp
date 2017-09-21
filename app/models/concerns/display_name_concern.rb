module DisplayNameConcern
  extend ActiveSupport::Concern

  included do
    def display_name
      "#{year}/#{year + 1} #{name}"
    end
  end
end
