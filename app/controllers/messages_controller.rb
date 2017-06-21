class MessagesController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @messages = @project.messages
  end

  def new
    @project = Project.find(params[:project_id])
    @message = Message.new
    @message.project = @project
  end

  def edit
    edit_setup
  end

  def create
    @project = Project.find(params[:project_id])
    @message = Message.new(create_params)
    @message.project = @project
    @message.duplicate_from_arxml(params[:message][:duplicate_source])
    if @message.save
      redirect_to project_messages_path(@project)
    else
      render :new
    end
  end

  def update
    @message = Message.find(params[:id])
    if @message.update_attributes(edit_params)
      redirect_to project_messages_path(project_id: @message.project_id)
    else
      #      @signs = Sign.getOwnSigns(session[:project])
      render :edit
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @project = @message.project
    flash[:danger] = 'メッセージの削除に失敗しました' unless @message.destroy
    redirect_to project_messages_path(@project)
  end

  def export
    @project = Project.find(params[:project_id])
    send_data @project.export_dbc, filename: @project.name + '.dbc'
  end

  def import
    @project = Project.find(params[:project_id])
    uploadfile = params[:file]
    if uploadfile
      messages = @project.import_dbc(uploadfile)
      flash[:import_info] = view_context.import_messages(@project.id, messages)
    else
      flash[:danger] = 'ファイルを選択してください'
    end

    redirect_to project_messages_path(@project)
  end

  def add_signal
    @message = Message.find(params[:id])
    # default com_signal
    c = @message.com_signals_build
    #    c.sign_id    = @message.unused_sign
    c.bit_offset = @message.unused_bit
    c.bit_size   = 1

    if c.save
      redirect_to :edit_message
    else
      edit_setup
      c.errors.full_messages.each { |msg| @message.errors[:com_signals] << msg }
      render :edit
    end
  end

  def del_signal
    c = ComSignal.find(params[:com_signal_id])
    if c.destroy
      redirect_to :edit_message
    else
      edit_setup
      c.errors.full_messages.each { |msg| @message.errors[:com_signals] << msg }
      render :edit
    end
  end

  def create_params
    { name: params[:message][:name] }
  end

  def edit_params
    begin
      params[:message][:canid] = Integer(params[:message][:canid]).to_s
    rescue
    end
    params.require(:message).permit(
      :data_frame, :canid, :txrx, :bytesize, :baudrate,
      com_signals_attributes: [:project_id, :data_type, :initial_value, :id, :name, :unit, :description, :bit_offset, :bit_size, :sign_id])
  end

  def correct_message
    @message = Message.find(params[:id])
    redirect_to root_url unless current_message?(@message)
  end

  private

  def edit_setup
    @message = Message.find(params[:id])
    return nil unless @message.nil?
    flash[:danger] = '選択されたメッセージが存在しません'
    redirect_to project_messages_path(@message.project)
    #    @signs = Sign.getOwnSigns(session[:project])
    #    if @signs.nil?
    #      flash[:danger] = '符号が存在しません'
    #      redirect_to messages_path
    #    end
  end

end
