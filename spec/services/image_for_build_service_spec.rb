require 'spec_helper'

describe ImageForBuildService do
  let(:service) { described_class.new }
  let(:project) { FactoryGirl.create(:project) }
  let(:commit) { FactoryGirl.create(:commit, project: project, ref: 'master') }
  let(:build) { FactoryGirl.create(:build, commit: commit) }

  describe '#execute' do
    before { build }

    context 'branch name' do
      before { build.run! }
      let(:image) { service.execute(project, ref: 'master') }

      it { expect(image).to be_kind_of(OpenStruct) }
      it { expect(image.path.to_s).to include('public/build-running.svg') }
      it { expect(image.name).to eq 'build-running.svg' }
    end

    context 'unknown branch name' do
      let(:image) { service.execute(project, ref: 'feature') }

      it { expect(image).to be_kind_of(OpenStruct) }
      it { expect(image.path.to_s).to include('public/build-unknown.svg') }
      it { expect(image.name).to eq 'build-unknown.svg' }
    end

    context 'commit sha' do
      before { build.run! }
      let(:image) { service.execute(project, sha: build.sha) }

      it { expect(image).to be_kind_of(OpenStruct) }
      it { expect(image.path.to_s).to include('public/build-running.svg') }
      it { expect(image.name).to eq 'build-running.svg' }
    end

    context 'unknown commit sha' do
      let(:image) { service.execute(project, sha: '0000000') }

      it { expect(image).to be_kind_of(OpenStruct) }
      it { expect(image.path.to_s).to include('public/build-unknown.svg') }
      it { expect(image.name).to eq 'build-unknown.svg' }
    end
  end
end
