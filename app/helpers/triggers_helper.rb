module TriggersHelper
  def build_trigger_url(project_id, ref_name)
    "#{Settings.gitlab_ci.url}/api/v1/projects/#{project_id}/refs/#{ref_name}/trigger"
  end
end
