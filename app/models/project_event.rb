class ProjectEvent < ApplicationRecord
  def self.earliest
    self.first.next_event
  end
end
