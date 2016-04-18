require 'spec_helper'

describe API::API do
  include ApiHelpers
  include StubGitlabCalls

  before {
    stub_gitlab_calls
  }

  describe "GET /runners" do
    let(:gitlab_url) { GitlabCi.config.gitlab_server.url }
    let(:private_token) { Network.new.authenticate(access_token: "some_token")["private_token"] }
    let(:options) {
      {
        :private_token => private_token,
        :url => gitlab_url
      }
    }

    before do
      5.times { FactoryGirl.create(:runner) }
    end

    it "should retrieve a list of all runners" do
      get api("/runners"), options
      expect(response.status).to eq 200
      expect(json_response.count).to eq 5
      expect(json_response.last).to have_key("id")
      expect(json_response.last).to have_key("token")
    end
  end

  describe "POST /runners/register" do
    describe "should create a runner if token provided" do
      before { post api("/runners/register"), token: GitlabCi::REGISTRATION_TOKEN }

      it { expect(response.status).to eq 201 }
    end

    describe "should create a runner with description" do
      before { post api("/runners/register"), token: GitlabCi::REGISTRATION_TOKEN, description: "server.hostname" }

      it { expect(response.status).to eq 201 }
      it { expect(Runner.first.description).to eq "server.hostname" }
    end

    describe "should create a runner with tags" do
      before { post api("/runners/register"), token: GitlabCi::REGISTRATION_TOKEN, tag_list: "tag1, tag2" }

      it { expect(response.status).to eq 201 }
      it { expect(Runner.first.tag_list.sort).to eq ["tag1", "tag2"] }
    end

    describe "should create a runner if project token provided" do
      let(:project) { FactoryGirl.create(:project) }
      before { post api("/runners/register"), token: project.token }

      it { expect(response.status).to eq 201 }
      it { expect(project.runners.size).to eq 1 }
    end

    it "should return 403 error if token is invalid" do
      post api("/runners/register"), token: 'invalid'

      expect(response.status).to eq 403
    end

    it "should return 400 error if no token" do
      post api("/runners/register")

      expect(response.status).to eq 400
    end
  end

  describe "DELETE /runners/delete" do
    let!(:runner) { FactoryGirl.create(:runner) }
    before { delete api("/runners/delete"), token: runner.token }

    it { expect(response.status).to eq 200 }
    it { expect(Runner.count).to eq 0 }
  end
end
