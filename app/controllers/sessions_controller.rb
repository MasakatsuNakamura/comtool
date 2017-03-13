class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(name: params[:session][:name])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to home_index_path
    else
      redirect_to root_path, notice: "ログインに失敗しました。ユーザ名、パスワードをもう一度確認してください。"
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
