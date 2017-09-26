RSpec.shared_examples :name_email do
  describe "#name_email" do
    it("is defined") { is_expected.to respond_to(:name_email) }

    it("returns the name") { expect(subject.name_email).to include(subject.name) }

    it("returns the email") { expect(subject.name_email).to include(subject.email) }
  end
end
