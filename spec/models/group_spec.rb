require 'rails_helper'
require_relative './examples/display_name'

RSpec.describe Group, type: :model do
  subject { build(described_class.name.underscore.to_sym) }

  context "validations" do
    it("requires a year") { is_expected.to validate_presence_of(:year) }
    it("requires a name") { is_expected.to validate_presence_of(:name) }
    it("requires an admin") { is_expected.to validate_presence_of(:admin) }

    it("requires a unique (year, name) tuple") { is_expected.to validate_uniqueness_of(:name).scoped_to(:year) }
  end

  include_examples :display_name
end
