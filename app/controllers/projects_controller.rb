class ProjectsController < ApplicationController
  before_action :find_master, only: [:create, :new, :update]
  def index; end

  def new
    @project = Project.new
    # TODO: 将来マスターが増えるかもしれないので一応SQL文を発行しておく
  end

  # POST /projects
  def create
    @project = Project.new(name: params[:project][:name])
    @project.communication_protocol = CommunicationProtocol.find_by_name(params[:communication_protocol][:name])
    @project.qines_version = QinesVersion.find_by_name(params[:qines_version_number][:name])
    if @project.save
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

    if @project.update(sample_params)
      redirect_to @project
    else
      flash[:danger] = 'プロジェクトの更新に失敗しました'
      render :edit
    end
  end

  def show
    @project = Project.find_by_id(params[:id])
    if @project == nil
      flash[:danger] = '選択されたプロジェクトが存在しません'
      redirect_to home_index_path
    end
  end

  private
  def find_master
    @qines_version_number = QinesVersion.find_by_name('V1.0')
    @communication_protocol = CommunicationProtocol.find_by_name('CAN')
  end
end
