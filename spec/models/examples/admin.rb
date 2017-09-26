RSpec.shared_examples :admin? do |expected|
  describe "#admin?" do
    it("is defined") { is_expected.to respond_to(:admin?) }

    it("returns #{expected}") { expect(subject.admin?).to eq(expected) }
  end
end
