RSpec.shared_examples :display_name do
  describe "#display_name" do
    it("is defined") { is_expected.to respond_to(:display_name) }

    it("returns name") { expect(subject.display_name).to include(subject.name) }

    it("returns school year") do
      display_name = subject.display_name
      expect(display_name).to include(subject.year.to_s)
      expect(display_name).to include((subject.year + 1).to_s)
    end
  end
end