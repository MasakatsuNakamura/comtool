class ProjectsController < ApplicationController
  before_action :find_master, only: [:create, :new, :update]
  def index
    redirect_to welcome_path unless signed_in?
    #    @projects = Project.where(project_id: User.where(project_id: params[:project_id]).select(project_id))
    @projects = Project.all
  end

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
      redirect_to projects_path
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    @project.name = params[:project][:name]
    @project.byte_order = params[:project][:byte_order]

    if @project.update(sample_params)
      redirect_to @project
    else
      flash[:danger] = 'プロジェクトの更新に失敗しました'
      render :edit
    end
  end

  def show
    @project = Project.find(params[:id])
    return nil unless @project.nil?
    redirect_to projects_path, danger: '選択されたプロジェクトが存在しません'
  end

  def export_ecuc
    @project = Project.find(params[:id])
    arxml = @project.to_ecuc_arxml
    if arxml.nil?
      raise 'invalid qines version'
    else
      send_data arxml, filename: 'Ecuc.arxml'
    end
  end

  def export_systemdesign
    @project = Project.find(params[:id])
    arxml = @project.to_systemdesign_arxml
    if arxml.nil?
      raise 'invalid qines version'
    else
      send_data arxml, filename: 'SystemDesign.arxml'
    end
  end

  private

  def find_master
    @qines_version_number = :v2_0
    @communication_protocol = :can
  end

  # TODO: disabled タスク #654
  def create_sign(name, project)
    Sign.create!(name: name, active: '1', vartype:'2', unit:'3',
    exchange_rate:'4.0', priority:'5', input_module:'6', output_moduel:'7',
    input_period:'8', output_period:'9', access_level:'10', project:project,
    description: "project:#{project.name},name:#{name}")
  end

  def project_params
    params.require(:project).permit(:name, :communication_protocol_id, :qines_version_id, :byte_order)
  end
end
