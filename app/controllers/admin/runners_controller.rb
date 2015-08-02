class Admin::RunnersController < Admin::ApplicationController
  before_filter :runner, except: :index

  def index
    @runners = Runner.order('id DESC')
    @runners = @runners.search(params[:search]) if params[:search].present?
    @runners = @runners.page(params[:page]).per(30)
    @active_runners_cnt = Runner.where("contacted_at > ?", 1.minutes.ago).count
  end

  def show
    @builds = @runner.builds.order('id DESC').first(30)
    @projects = Project.all
    @projects = @projects.search(params[:search]) if params[:search].present?
    @projects = @projects.where("projects.id NOT IN (?)", @runner.projects.pluck(:id)) if @runner.projects.any?
    @projects = @projects.page(params[:page]).per(30)
  end

  def update
    @runner.update_attributes(runner_params)

    respond_to do |format|
      format.js
      format.html { redirect_to admin_runner_path(@runner) }
    end
  end

  def destroy
    @runner.destroy

    redirect_to admin_runners_path
  end

  def resume
    if @runner.update_attributes(active: true)
      redirect_to admin_runners_path, notice: 'Runner was successfully updated.'
    else
      redirect_to admin_runners_path, alert: 'Runner was not updated.'
    end
  end

  def pause
    if @runner.update_attributes(active: false)
      redirect_to admin_runners_path, notice: 'Runner was successfully updated.'
    else
      redirect_to admin_runners_path, alert: 'Runner was not updated.'
    end
  end

  def assign_all
    Project.unassigned(@runner).all.each do |project|
      @runner.assign_to(project, current_user)
    end

    redirect_to admin_runner_path(@runner), notice: "Runner was assigned to all projects"
  end

  private

  def runner
    @runner ||= Runner.find(params[:id])
  end

  def runner_params
    params.require(:runner).permit(:token, :description, :tag_list, :contacted_at, :active)
  end
end
