require 'spec_helper'

describe "Admin Builds", feature: true do
  let(:project) { FactoryGirl.create :project }
  let(:commit) { FactoryGirl.create :commit, project: project }
  let(:build) { FactoryGirl.create :build, commit: commit }

  before do
    skip_admin_auth
    login_as :user
  end

  describe "GET /admin/builds" do
    before do
      build
      visit admin_builds_path
    end

    it { expect(page).to have_content "All builds" }
    it { expect(page).to have_content build.short_sha }
  end

  describe "Tabs" do
    it "shows all builds" do
      build = FactoryGirl.create :build, commit: commit, status: "pending"
      build1 = FactoryGirl.create :build, commit: commit, status: "running"
      build2 = FactoryGirl.create :build, commit: commit, status: "success"
      build3 = FactoryGirl.create :build, commit: commit, status: "failed"

      visit admin_builds_path

      expect(page.all(".build-link").size).to eq 4
    end

    it "shows pending builds" do
      build = FactoryGirl.create :build, commit: commit, status: "pending"
      build1 = FactoryGirl.create :build, commit: commit, status: "running"
      build2 = FactoryGirl.create :build, commit: commit, status: "success"
      build3 = FactoryGirl.create :build, commit: commit, status: "failed"

      visit admin_builds_path

      within ".nav.nav-tabs" do
        click_on "Pending"
      end

      expect(page.find(".build-link")).to have_content(build.id)
      expect(page.find(".build-link")).not_to have_content(build1.id)
      expect(page.find(".build-link")).not_to have_content(build2.id)
      expect(page.find(".build-link")).not_to have_content(build3.id)
    end

    it "shows running builds" do
      build = FactoryGirl.create :build, commit: commit, status: "pending"
      build1 = FactoryGirl.create :build, commit: commit, status: "running"
      build2 = FactoryGirl.create :build, commit: commit, status: "success"
      build3 = FactoryGirl.create :build, commit: commit, status: "failed"

      visit admin_builds_path

      within ".nav.nav-tabs" do
        click_on "Running"
      end

      expect(page.find(".build-link")).to have_content(build1.id)
      expect(page.find(".build-link")).not_to have_content(build.id)
      expect(page.find(".build-link")).not_to have_content(build2.id)
      expect(page.find(".build-link")).not_to have_content(build3.id)
    end
  end
end
