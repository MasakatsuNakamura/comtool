class SessionsController < ApplicationController
  def new
    redirect_to projects_path if signed_in?
  end

  def create
    user = User.find_by(name: params[:session][:name])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      flash[:success] = 'ログインしました'
      redirect_to projects_path
    else
      flash[:warning] = 'ログインに失敗しました。ユーザ名、パスワードを確認してください。'
      redirect_to signin_path
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
