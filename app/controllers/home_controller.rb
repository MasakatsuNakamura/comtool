class HomeController < ApplicationController
  def index
    @projects = Project.getOwnProjects(current_user)
  end
end
