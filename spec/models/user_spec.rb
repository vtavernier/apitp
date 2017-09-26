require 'rails_helper'
require_relative './examples/name_email'
require_relative './examples/admin'

RSpec.describe User, type: :model do
  subject { build(described_class.name.underscore.to_sym) }

  context "validations" do
    it("requires a name") { is_expected.to validate_presence_of(:name) }
    it("requires an email") { is_expected.to validate_presence_of(:email) }
    it("requires a unique email") { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  include_examples :name_email

  include_examples :admin?, false

  describe "#super_admin?" do
    it("is defined") { is_expected.to respond_to(:super_admin?) }
    it("returns false") { expect(subject.super_admin?).to eq(false) }
  end
end
