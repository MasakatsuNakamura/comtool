class StaticPagesController < ApplicationController
  def welcome
    redirect_to projects_path if signed_in?
  end

  def help
  end

  def about
  end

  def contact
  end
end
