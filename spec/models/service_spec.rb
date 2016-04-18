# == Schema Information
#
# Table name: services
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  title      :string(255)
#  project_id :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  active     :boolean          default(FALSE), not null
#  properties :text
#

require 'spec_helper'

describe Service do

  describe "Associations" do
    it { is_expected.to belong_to :project }
  end

  describe "Mass assignment" do
  end

  describe "Test Button" do
    before do
      @service = described_class.new
    end

    describe "Testable" do
      let (:project) { FactoryGirl.create :project }
      let (:commit) { FactoryGirl.create :commit, project: project }
      let (:build) { FactoryGirl.create :build, commit: commit }

      before do
        allow(@service).to receive_messages(project: project)
        build
        @testable = @service.can_test?
      end

      describe '#can_test' do
        it { expect(@testable).to eq true }
      end
    end
  end
end
