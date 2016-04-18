module StubGitlabCalls
  def stub_gitlab_calls
    stub_session
    stub_user
    stub_project_8
    stub_project_8_hooks
    stub_projects
    stub_projects_owned
    stub_ci_enable
  end

  def stub_js_gitlab_calls
    Network.any_instance.stub(:projects) { project_hash_array }
  end

  private

  def gitlab_url
    GitlabCi.config.gitlab_server.url
  end

  def stub_session
    f = File.read(Rails.root.join('spec/support/gitlab_stubs/session.json'))

    stub_request(:post, "#{gitlab_url}api/v3/session.json").
      with(:body => "{\"email\":\"test@test.com\",\"password\":\"123456\"}",
           :headers => {'Content-Type'=>'application/json'}).
           to_return(:status => 201, :body => f, :headers => {'Content-Type'=>'application/json'})
  end

  def stub_user
    f = File.read(Rails.root.join('spec/support/gitlab_stubs/user.json'))

    stub_request(:get, "#{gitlab_url}api/v3/user?private_token=Wvjy2Krpb7y8xi93owUz").
      with(:headers => {'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => f, :headers => {'Content-Type'=>'application/json'})

    stub_request(:get, "#{gitlab_url}api/v3/user?access_token=some_token").
      with(:headers => {'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => f, :headers => {'Content-Type'=>'application/json'})
  end

  def stub_project_8
    data = File.read(Rails.root.join('spec/support/gitlab_stubs/project_8.json'))
    Network.any_instance.stub(:project).and_return(JSON.parse(data))
  end

  def stub_project_8_hooks
    data = File.read(Rails.root.join('spec/support/gitlab_stubs/project_8_hooks.json'))
    Network.any_instance.stub(:project_hooks).and_return(JSON.parse(data))
  end

  def stub_projects
    f = File.read(Rails.root.join('spec/support/gitlab_stubs/projects.json'))
   
    stub_request(:get, "#{gitlab_url}api/v3/projects.json?archived=false&ci_enabled_first=true&private_token=Wvjy2Krpb7y8xi93owUz").
      with(:headers => {'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => f, :headers => {'Content-Type'=>'application/json'})
  end

  def stub_projects_owned
    stub_request(:get, "#{gitlab_url}api/v3/projects/owned.json?archived=false&ci_enabled_first=true&private_token=Wvjy2Krpb7y8xi93owUz").
      with(:headers => {'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => "", :headers => {})
  end

  def stub_ci_enable
    stub_request(:put, "#{gitlab_url}api/v3/projects/2/services/gitlab-ci.json?private_token=Wvjy2Krpb7y8xi93owUz").
      with(:headers => {'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => "", :headers => {})
  end

  def project_hash_array
    f = File.read(Rails.root.join('spec/support/gitlab_stubs/projects.json'))
    return JSON.parse f
  end
end
