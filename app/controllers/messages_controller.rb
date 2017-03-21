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
    @signs = Sign.getOwnSigns(session[:project])
    if @signs.nil?
      redirect_to messages_path, notice: '符号が存在しません'
    end
  end

  def create
    @message = Message.duplicate_from_arxml(create_params, project: session[:project], duplicate_source: params[:message][:duplicate_source])
    if @message.save
      redirect_to :messages, notice: 'Message was created.'
    else
      render :new, notice: 'Failed to create a message.'
    end
  end

  def update
    @message = Message.find_by_id(params[:id])
    if @message.update_attributes(edit_params)
      redirect_to :messages
    else
      redirect_to :messages, notice: 'メッセージの更新に失敗しました'
    end
  end

  def destroy
    @message = Message.find_by_id(params[:id])
    if @message.destroy
      redirect_to :messages
    else
      redirect_to :messages, notice: 'メッセージの削除に失敗しました'
    end
  end

  def create_params
    {:name     => params[:message][:name]}
  end

  def edit_params
    params.require(:message).permit(
      :canid,:txrx,:bytesize,:baudrate,
      com_signals_attributes: [:id, :name, :unit, :description, :bit_offset, :bit_size, :sign_id])
  end

  def correct_message
    @message = Message.find(params[:id])
    redirect_to root_url unless current_message?(@message)
  end

  private
  def duplicate_from ()
  end

end
