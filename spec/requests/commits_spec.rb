require 'spec_helper'

describe "Commits" do
  before do
    @project = FactoryGirl.create :project
    @commit = FactoryGirl.create :commit, project: @project
  end

  describe "GET /:project/refs/:ref_name/commits/:id/status.json" do
    before do
      get status_project_ref_commit_path(@project, @commit.ref, @commit.sha), format: :json
    end

    it { expect(response.status).to eq 200 }
    it { expect(response.body).to include(@commit.sha) }
  end
end
