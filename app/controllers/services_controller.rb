class ServicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_access_project!
  before_filter :authorize_manage_project!
  before_filter :service, only: [:edit, :update, :test]

  respond_to :html

  layout 'project'

  def index
    @project.build_missing_services
    @services = @project.services.reload
  end

  def edit
  end

  def update
    if @service.update_attributes(service_params)
      redirect_to edit_project_service_path(@project, @service.to_param), notice: 'Service was successfully updated.'
    else
      render 'edit'
    end
  end

  def test
    last_build = @project.builds.last

    if @service.execute(last_build)
      message = { notice: 'We successfully tested the service' }
    else
      message = { alert: 'We tried to test the service but error occured' }
    end

    redirect_to :back, message
  end

  private

  def project
    @project = Project.find(params[:project_id])
  end

  def service
    @service ||= @project.services.find { |service| service.to_param == params[:id] }
  end

  def service_params
    params.require(:service).permit(
      :type, :active, :webhook, :notify_only_broken_builds,
      :email_recipients, :email_only_broken_builds, :email_add_pusher,
      :hipchat_token, :hipchat_room, :hipchat_server
    )
  end
end
