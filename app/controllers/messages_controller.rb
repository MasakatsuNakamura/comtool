class MessagesController < ApplicationController
  def index
    session[:project]  = params[:project] unless params[:project].nil?
    @messages = Message.getOwnMessages(session[:project])
  end

  def new
    @message = Message.new
  end

  def edit
    @message = Message.find_by_id(params[:id])
    if @message.nil?
      redirect_to messages_path, notice: '選択されたメッセージが存在しません'
    end
    @signs = Sign.getOwnSigns(session[:project]).select(:name)
    if @signs.nil?
      redirect_to messages_path, notice: '符号が存在しません'
    end
  end

  def create
    @message = Message.duplicate_from_arxml(message_params, params[:message][:duplicate_source])
    #TODO duplicate_sourceからarxmlを指定する
    @message.project = Project.find_by_id(session[:project])

    if @message.save
      redirect_to :messages, notice: 'Message was created.'
    else
      render :new, notice: 'Failed to create a message.'
    end
  end

  def update
    @message = Message.find_by_id(params[:id])
    if @message.update_attributes(signal_params)
      redirect_to :messages
    else
      render :edit
    end
  end

  def message_params
    {:name => params[:message][:name]}
  end

  def signal_params
    params.require(:message).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def correct_message
    @message = Message.find(params[:id])
    redirect_to root_url unless current_message?(@message)
  end

  private
  def duplicate_from ()
  end

end
