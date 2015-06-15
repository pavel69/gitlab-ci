class Notify < ActionMailer::Base
  include Emails::Builds

  add_template_helper ApplicationHelper
  add_template_helper GitlabHelper

  default_url_options[:host]     = GitlabCi.config.gitlab_ci.host
  default_url_options[:protocol] = GitlabCi.config.gitlab_ci.protocol
  default_url_options[:port]     = GitlabCi.config.gitlab_ci.port if GitlabCi.config.gitlab_ci_on_non_standard_port?
  default_url_options[:script_name] = GitlabCi.config.gitlab_ci.relative_url_root

  default from: GitlabCi.config.gitlab_ci.email_from

  # Just send email with 3 seconds delay
  def self.delay
    delay_for(2.seconds)
  end

  private

  # Formats arguments into a String suitable for use as an email subject
  #
  # extra - Extra Strings to be inserted into the subject
  #
  # Examples
  #
  #   >> subject('Lorem ipsum')
  #   => "GitLab-CI | Lorem ipsum"
  #
  #   # Automatically inserts Project name when @project is set
  #   >> @project = Project.last
  #   => #<Project id: 1, name: "Ruby on Rails", path: "ruby_on_rails", ...>
  #   >> subject('Lorem ipsum')
  #   => "GitLab-CI | Ruby on Rails | Lorem ipsum "
  #
  #   # Accepts multiple arguments
  #   >> subject('Lorem ipsum', 'Dolor sit amet')
  #   => "GitLab-CI | Lorem ipsum | Dolor sit amet"
  def subject(*extra)
    subject = "GitLab-CI"
    subject << (@project ? " | #{@project.name}" : "")
    subject << " | " + extra.join(' | ') if extra.present?
    subject
  end
end
