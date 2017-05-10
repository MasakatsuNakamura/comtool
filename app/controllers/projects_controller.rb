class ProjectsController < ApplicationController
  before_action :find_master, only: [:create, :new, :update]
  def index; end

  def new
    @project = Project.new
    # TODO: 将来マスターが増えるかもしれないので一応SQL文を発行しておく
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    # TODO:disabled タスク #654
    # params[:project][:duplicate_source].to_i.times { |cnt|
    #   create_sign("PPort#{cnt}", @project)
    #   create_sign("RPort#{cnt}", @project)
    # }

    if @project.save
      DatabaseManage.create!(backup_file_path: 'CAN/test',backup_date: Date.today, project: @project)
      redirect_to home_index_path
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    @project.name =  params[:project][:name]
    @project.communication_protocol = CommunicationProtocol.find_by_name(params[:qines_version_number][:name])
    @project.qines_version = QinesVersion.find_by_name(params[:communication_protocol][:name])
    @project.byte_order = params[:project][:byte_order]

    if @project.update(sample_params)
      redirect_to @project
    else
      flash[:danger] = 'プロジェクトの更新に失敗しました'
      render :edit
    end
  end

  def show
    @project = Project.find_by_id(params[:id])
    session[:project]  = params[:id]
    if @project == nil
      flash[:danger] = '選択されたプロジェクトが存在しません'
      redirect_to home_index_path
    end
  end

  private
  def find_master
    @qines_version_number = QinesVersion.find_by_name('V2.0')
    @communication_protocol = CommunicationProtocol.find_by_name('CAN')
  end

  # TODO:disabled タスク #654
  def create_sign(name, project )
    Sign.create!(name: name, active: '1', vartype:'2', unit:'3',
    exchange_rate:'4.0', priority:'5', input_module:'6', output_moduel:'7',
    input_period:'8', output_period:'9', access_level:'10', project:project,
    description: "project:#{project.name},name:#{name}")
  end

  def project_params
    params[:project][:communication_protocol_id] = CommunicationProtocol.find_by_name(params[:communication_protocol][:name]).id
    params[:project][:qines_version_id]          = QinesVersion.find_by_name(params[:qines_version_number][:name]).id

    params.require(:project).permit(:name, :communication_protocol_id, :qines_version_id, :byte_order)
  end
end
