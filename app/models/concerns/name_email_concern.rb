module NameEmailConcern
  extend ActiveSupport::Concern

  included do
    def name_email
      "#{name} <#{email}>"
    end
  end
end
