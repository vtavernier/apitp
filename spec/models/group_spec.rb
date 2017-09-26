require 'rails_helper'

RSpec.describe Group, type: :model do
  subject { build(described_class.name.underscore.to_sym) }

  context "validations" do
    it("requires a year") { is_expected.to validate_presence_of(:year) }
    it("requires a name") { is_expected.to validate_presence_of(:name) }
    it("requires an admin") { is_expected.to validate_presence_of(:admin) }

    it("requires a unique (year, name) tuple") { is_expected.to validate_uniqueness_of(:name).scoped_to(:year) }
  end

  context "name methods" do
    it("responds to #display_name") { is_expected.to respond_to(:display_name) }
  end
end
