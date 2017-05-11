class HomeController < ApplicationController
  def index
    redirect_to welcome_path unless signed_in?
    #    @projects = Project.where(project_id: User.where(project_id: params[:project_id]).select(project_id))
    @projects = Project.all
  end
end
