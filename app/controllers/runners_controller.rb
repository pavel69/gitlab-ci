class RunnersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :set_runner, only: [:edit, :update, :destroy, :pause, :resume, :show]
  before_filter :authorize_access_project!
  before_filter :authorize_manage_project!

  layout 'project'

  def index
    @runners = @project.runners.order('id DESC')
    @specific_runners = current_user.authorized_runners.
      where.not(id:  @runners).order('runners.id DESC').page(params[:page]).per(20)
    @shared_runners = Runner.shared.active
    @shared_runners_count = @shared_runners.count(:all)
  end

  def edit
  end

  def update
    if @runner.update_attributes(runner_params)
      redirect_to edit_project_runner_path(@project, @runner), notice: 'Runner was successfully updated.'
    else
      redirect_to edit_project_runner_path(@project, @runner), alert: 'Runner was not updated.'
    end
  end

  def destroy
    if @runner.only_for?(@project)
      @runner.destroy
    end

    redirect_to project_runners_path(@project)
  end

  def resume
    if @runner.update_attributes(active: true)
      redirect_to project_runners_path(@project, @runner), notice: 'Runner was successfully updated.'
    else
      redirect_to project_runners_path(@project, @runner), alert: 'Runner was not updated.'
    end
  end

  def pause
    if @runner.update_attributes(active: false)
      redirect_to project_runners_path(@project, @runner), notice: 'Runner was successfully updated.'
    else
      redirect_to project_runners_path(@project, @runner), alert: 'Runner was not updated.'
    end
  end

  def show
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end

  def set_runner
    @runner ||= @project.runners.find(params[:id])
  end

  def runner_params
    params.require(:runner).permit(:description, :tag_list, :contacted_at, :active)
  end
end
