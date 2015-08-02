class CommitsController < ApplicationController
  before_filter :authenticate_user!, except: [:status, :show]
  before_filter :authenticate_public_page!, only: :show
  before_filter :project
  before_filter :authorize_access_project!, except: [:status, :show, :cancel]
  before_filter :authorize_project_developer!, only: [:cancel]
  before_filter :commit, only: :show

  def show
    @builds = @commit.builds
  end

  def status
    commit = Project.find(params[:project_id]).commits.find_by_sha_and_ref!(params[:id], params[:ref_id])
    render json: commit.to_json(only: [:id, :sha], methods: [:status, :coverage])
  rescue ActiveRecord::RecordNotFound
    render json: { status: "not_found" }
  end

  def cancel
    commit.builds.running_or_pending.each(&:cancel)

    redirect_to project_ref_commit_path(project, commit.ref, commit.sha)
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end

  def commit
    @commit ||= Project.find(params[:project_id]).commits.find_by_sha_and_ref!(params[:id], params[:ref_id])
  end
end
