# User object is stored in session
class User
  DEVELOPER_ACCESS = 30

  attr_reader :attributes

  def initialize(hash)
    @attributes = hash
  end

  def gitlab_projects(search = nil, page = 1, per_page = 100)
    Rails.cache.fetch(cache_key(page, per_page, search)) do
      Project.from_gitlab(self, :authorized, { page: page, per_page: per_page, search: search, ci_enabled_first: true })
    end
  end

  def method_missing(meth, *args, &block)
    if attributes.has_key?(meth.to_s)
      attributes[meth.to_s]
    else
      super
    end
  end

  def cache_key(*args)
    "#{self.id}:#{args.join(":")}:#{sync_at.to_s}"
  end

  def sync_at
    @sync_at ||= Time.now
  end

  def reset_cache
    @sync_at = Time.now
  end

  def can_access_project?(project_gitlab_id)
    !!project_info(project_gitlab_id)
  end

  # Indicate if user has developer access or higher
  def has_developer_access?(project_gitlab_id)
    data = project_info(project_gitlab_id)

    return false unless data && data["permissions"]

    permissions = data["permissions"]

    if permissions["project_access"] && permissions["project_access"]["access_level"] >= DEVELOPER_ACCESS
      return true
    end

    if permissions["group_access"] && permissions["group_access"]["access_level"] >= DEVELOPER_ACCESS
      return true
    end
  end

  def can_manage_project?(project_gitlab_id)
    opts = {
      private_token: self.private_token,
    }

    Rails.cache.fetch(cache_key('manage', project_gitlab_id, sync_at)) do
      !!Network.new.project_hooks(opts, project_gitlab_id)
    end
  end

  def authorized_runners
    Runner.specific.includes(:runner_projects).
      where(runner_projects: { project_id: authorized_projects } )
  end

  def authorized_projects
    @authorized_projects ||= Project.where(gitlab_id: gitlab_projects.map(&:id))
  end

  private

  def project_info(project_gitlab_id)
    opts = {
      private_token: self.private_token,
    }

    Rails.cache.fetch(cache_key("project_info", project_gitlab_id, sync_at)) do
      Network.new.project(opts, project_gitlab_id)
    end
  end
end
