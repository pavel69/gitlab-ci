require 'spec_helper'

describe EventService do
  let (:project) { FactoryGirl.create :project, name: "GitLab / gitlab-shell" }
  let (:user)   { double(username: "root", id: 1) }

  before do
    Event.destroy_all
  end
  
  describe '#remove_project' do
    it "creates event" do
      described_class.new.remove_project(user, project)

      expect(Event.admin.last.description).to eq "Project \"GitLab / gitlab-shell\" has been removed by root"
    end
  end

  describe '#create_project' do
    it "creates event" do
      described_class.new.create_project(user, project)

      expect(Event.admin.last.description).to eq "Project \"GitLab / gitlab-shell\" has been created by root"
    end
  end

  describe '#change_project_settings' do
    it "creates event" do
      described_class.new.change_project_settings(user, project)

      expect(Event.last.description).to eq "User \"root\" updated projects settings"
    end
  end
end
