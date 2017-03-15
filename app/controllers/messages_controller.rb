class MessagesController < ApplicationController
  def index
    session[:project]  = params[:project] unless params[:project].nil?
    @messages = Message.getOwnMessages(session[:project])
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    #TODO duplicate_sourceからarxmlを指定する
    #TODO projectを指定する
    @message.project = Project.find_by_id(session[:project])
    if @message.save
      redirect_to :messages, notice: 'Message was created.'
    else
      render :new, notice: 'Failed to create a message.'
    end
  end

  def show
    @message = Message.find_by_id(params[:id])
    if @message == nil
      redirect_to home_index_path, notice: '選択されたメッセージが存在しません'
    end
  end

  def message_params
    {:name => params[:message][:name]}
  end

  def correct_message
    @message = Message.find(params[:id])
    redirect_to root_url unless current_message?(@message)
  end
end
