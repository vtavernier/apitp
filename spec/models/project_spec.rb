require 'rails_helper'
require_relative './examples/display_name'

RSpec.describe Project, type: :model do
  subject { build(described_class.name.underscore.to_sym) }

  context "validations" do
    it("requires a year") { is_expected.to validate_presence_of(:year) }
    it("requires a name") { is_expected.to validate_presence_of(:name) }
    it("requires a start time") { is_expected.to validate_presence_of(:start_time) }
    it("requires an end time") { is_expected.to validate_presence_of(:end_time) }
    it("requires a max upload size") { is_expected.to validate_presence_of(:max_upload_size) }
    it("requires a valid max upload size") do
      is_expected.to validate_numericality_of(:max_upload_size).is_greater_than(0).is_less_than_or_equal_to(Rails.configuration.x.apitp.max_upload_size)
    end
    it("requires an owner") { is_expected.to validate_presence_of(:owner) }
  end

  describe "#set_defaults" do
    subject { described_class.new }
    before(:each) { subject.set_defaults }

    it("does not set the owner") { expect(subject.owner).to be_nil }
    it("does not set the name") { expect(subject.name).to be_nil }
    it("sets all attributes required except owner and name") do
      subject.owner = create(:admin_user)
      subject.name = generate(:project_name)
      expect(subject).to be_valid
    end
  end

  describe "#stats" do
    before(:all) do
      @project = create(:project)
      @group = create(:group, admin: @project.owner)
      2.times { create(:user, groups: [@group]) }
      @project.groups << @group
      @project.save
    end

    subject { Project.stats.find(@project.id) }

    it("reports user count") { expect(subject.user_count).to eq(2) }
    it("reports submissions") { expect(subject.submission_count).to eq(0) }

    after(:all) do
      @project.destroy
      @group.users.destroy_all
      @group.destroy
    end
  end

  include_examples :display_name
end
