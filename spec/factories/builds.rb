# == Schema Information
#
# Table name: builds
#
#  id            :integer          not null, primary key
#  project_id    :integer
#  status        :string(255)
#  finished_at   :datetime
#  trace         :text
#  created_at    :datetime
#  updated_at    :datetime
#  started_at    :datetime
#  runner_id     :integer
#  commit_id     :integer
#  coverage      :float
#  commands      :text
#  job_id        :integer
#  name          :string(255)
#  deploy        :boolean          default(FALSE)
#  options       :text
#  allow_failure :boolean          default(FALSE), not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build do
    started_at 'Di 29. Okt 09:51:28 CET 2013'
    finished_at 'Di 29. Okt 09:53:28 CET 2013'
    commands 'ls -a'
    options do
      {
        image: "ruby:2.1",
        services: ["postgres"]
      }
    end

    factory :not_started_build do
      started_at nil
      finished_at nil
    end
  end
end
