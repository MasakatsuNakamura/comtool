class StaticPagesController < ApplicationController
  def welcome
    redirect_to home_index_path if signed_in?
  end

  def help
  end

  def about
  end

  def contact
  end
end
