require 'spec_helper'

describe RegisterBuildService do
  let!(:service) { described_class.new }
  let!(:project) { FactoryGirl.create :project }
  let!(:commit) { FactoryGirl.create :commit, project: project }
  let!(:pending_build) { FactoryGirl.create :build, project: project, commit: commit }
  let!(:shared_runner) { FactoryGirl.create(:runner, is_shared: true) }
  let!(:specific_runner) { FactoryGirl.create(:runner, is_shared: false) }

  before do
    specific_runner.assign_to(project)
  end

  describe '#execute' do
    context 'runner follow tag list' do
      it "picks build with the same tag" do
        pending_build.tag_list = ["linux"]
        pending_build.save
        specific_runner.tag_list = ["linux"]
        expect(service.execute(specific_runner)).to eq pending_build
      end

      it "does not pick build with different tag" do
        pending_build.tag_list = ["linux"]
        pending_build.save
        specific_runner.tag_list = ["win32"]
        expect(service.execute(specific_runner)).to be_falsey
      end

      it "picks build without tag" do
        expect(service.execute(specific_runner)).to eq pending_build
      end

      it "does not pick build with tag" do
        pending_build.tag_list = ["linux"]
        pending_build.save
        expect(service.execute(specific_runner)).to be_falsey
      end

      it "pick build without tag" do
        specific_runner.tag_list = ["win32"]
        expect(service.execute(specific_runner)).to eq pending_build
      end
    end

    context 'allow shared runners' do
      before do
        project.shared_runners_enabled = true
        project.save
      end

      context 'shared runner' do
        let(:build) { service.execute(shared_runner) }

        it { expect(build).to be_kind_of(Build) }
        it { expect(build).to be_valid }
        it { expect(build).to be_running }
        it { expect(build.runner).to eq shared_runner }
      end

      context 'specific runner' do
        let(:build) { service.execute(specific_runner) }

        it { expect(build).to be_kind_of(Build) }
        it { expect(build).to be_valid }
        it { expect(build).to be_running }
        it { expect(build.runner).to eq specific_runner }
      end
    end

    context 'disallow shared runners' do
      context 'shared runner' do
        let(:build) { service.execute(shared_runner) }

        it { expect(build).to be_nil }
      end

      context 'specific runner' do
        let(:build) { service.execute(specific_runner) }

        it { expect(build).to be_kind_of(Build) }
        it { expect(build).to be_valid }
        it { expect(build).to be_running }
        it { expect(build.runner).to eq specific_runner }
      end
    end
  end
end
