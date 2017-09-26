require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  subject { build(described_class.name.underscore.to_sym) }

  describe "validations" do
    it("requires a name") { is_expected.to validate_presence_of(:name) }
    it("requires a unique name") { is_expected.to validate_uniqueness_of(:name) }
    it("requires an email") { is_expected.to validate_presence_of(:email) }
    it("requires a unique email") { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "#name_email" do
    it("is defined") { is_expected.to respond_to(:name_email) }
    it("returns the name") { expect(subject.name_email).to include(subject.name) }
    it("returns the email") { expect(subject.name_email).to include(subject.email) }
  end

  describe "#admin?" do
    it("is defined") { is_expected.to respond_to(:admin?) }
    it("returns true") { expect(subject.admin?).to eq(true) }
  end

  describe "#super_admin?" do
    it("is defined") { is_expected.to respond_to(:super_admin?) }

    context "super admins" do
      before { subject.super_admin = true }
      it("returns true") { expect(subject.super_admin?).to eq(true) }
    end

    context "normal admins" do
      it("returns false") { expect(subject.super_admin?).to eq(false) }
    end
  end
end
