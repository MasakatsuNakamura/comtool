class MessagesController < ApplicationController
  def index
    session[:project]  = params[:project] unless params[:project].nil?
    @messages = Message.getOwnMessages(session[:project])
  end

  def new
    @message = Message.new
  end

  def edit
    edit_setup
  end

  def create
    @message = Message.duplicate_from_arxml(create_params, project: session[:project], duplicate_source: params[:message][:duplicate_source])
    if @message.save
      redirect_to :messages
    else
      render :new
    end
  end

  def update
    @message = Message.find_by_id(params[:id])
    if @message.update_attributes(edit_params)
      redirect_to :messages
    else
#      @signs = Sign.getOwnSigns(session[:project])
      render :edit
    end
  end

  def destroy
    @message = Message.find_by_id(params[:id])
    if @message.destroy
      redirect_to :messages
    else
      flash[:danger] = 'メッセージの削除に失敗しました'
      redirect_to :messages
    end
  end

  def export
    prj = Project.find_by_id(session[:project])
    dbc = MessagesHelper::DbcFileGenerator.generate(prj)
    # クライアントへダウンロード
    send_data(
      dbc,
      type: 'application/octet-stream',
      # 出力ファイル名
      filename: prj.name + '.dbc'
    )
  end

  def import
    uploadfile = params[:file]
    if uploadfile
      prj = Project.find_by_id(session[:project])
      messages = MessagesHelper::DbcFileParser.parse(prj, uploadfile.read)

      begin
        Message.transaction do
          messages.each do |m|
            exist_message = Message.find_by_name(m.name)
            if exist_message.nil?
              raise unless m.save
            else
              update_params = m.attributes.select { |k,v| k == :canid || k == :bytesize}
              raise unless exist_message.update_attributes update_params

              m.com_signals.each do |s|
                exist_com_signal = ComSignal.find_by_name(s.name)
                if exist_com_signal.nil?
                  raise unless s.save
                else
                  update_params = s.attributes.select { |k,v|
                    k == :description || k == :offset || k == :bit_size || k == :data_type || k == :unit }
                  raise unless exist_com_signal.update_attributes update_params
                end
              end
            end
          end
        end
        flash_msg = []
        messages.each do |m|
          signames = ""
          m.com_signals.each {|s| signames += s.name + ', ' }
          flash_msg << m.name + ' ( ' + signames + " ) "
        end
        flash[:success] = 'インポートしました'
        flash[:info]    = flash_msg.join("<br>").html_safe
      rescue => e
        error_msg = []
        error_msg << 'インポートに失敗しました。エラー内容を確認して下さい。'
        messages.each do |m|
          m.errors.full_messages.each {|msg|
            error_msg << m.name + '=>' + msg + ','
          }
        end
        flash[:danger] = error_msg.join("<br>").html_safe
      end
    else
      flash[:danger] = 'ファイルを選択してください'
    end
    redirect_to :messages
  end

  def add_signal
    @message = Message.find_by_id(params[:id])

#    sign_id = unused_sign(@message, session[:project])
    bit_offset = unused_bit(@message, session[:project])

    # default com_signal
    c = @message.com_signals_build

#    c.sign_id    = sign_id
    c.bit_offset = bit_offset
    c.bit_size   = 1

    if c.save
      redirect_to :edit_message
    else
      edit_setup
      c.errors.full_messages.each { |msg| @message.errors[:com_signals] << msg}
      render :edit
    end
  end

  def del_signal
    c = ComSignal.find_by_id(params[:com_signal_id])
    if c.destroy
      redirect_to :edit_message
    else
      edit_setup
      c.errors.full_messages.each { |msg| @message.errors[:com_signals] << msg}
      render :edit
    end
  end

  def create_params
    {:name     => params[:message][:name]}
  end

  def edit_params
    begin
      params[:message][:canid] = Integer(params[:message][:canid]).to_s
    rescue
    end
    params.require(:message).permit(
      :data_frame, :canid, :txrx, :bytesize, :baudrate,
      com_signals_attributes: [:data_type, :initial_value, :id, :name, :unit, :description, :bit_offset, :bit_size, :sign_id])
  end

  def correct_message
    @message = Message.find(params[:id])
    redirect_to root_url unless current_message?(@message)
  end

  private
  def edit_setup
    @message = Message.find_by_id(params[:id])
    if @message.nil?
      flash[:danger] = '選択されたメッセージが存在しません'
      redirect_to messages_path
    end
#    @signs = Sign.getOwnSigns(session[:project])
#    if @signs.nil?
#      flash[:danger] = '符号が存在しません'
#      redirect_to messages_path
#    end
  end

  def unused_sign(msg, pid)
    used_signs = []
    msg.com_signals.each { |c| used_signs << c.sign_id }

    unused_signs = Sign.getOwnSigns(pid).reject { |sign| used_signs.include?(sign.id) }

    if unused_signs.empty?
      nil
    else
      unused_signs[0].id
    end
  end

  def unused_bit(msg, pid)
    unused_bit = Array.new(msg.bytesize*8, true)

    project = Project.find_by_id(msg.project_id)

    msg.com_signals.each do |c|
      if project.little_endian? then
        c.bit_size.times do |bit|
          offset = bit + c.bit_offset
          unused_bit[offset] = false if offset < msg.bytesize*8
        end
      else
        offset = c.bit_offset
        bit_size = c.bit_size
        while bit_size > 0
          unused_bit[offset] = false if offset < msg.bytesize*8
          bit_size -= 1

          if offset % 8 == 0 then
            offset += 15
          else
            offset -= 1
          end
        end
      end
    end

    unused_bit.index(true)
  end

end
