class ProjectsController < ApplicationController
  before_action :set_project, only: %w[update show export_ecuc export_systemdesign]

  def index
    redirect_to welcome_path unless signed_in?
    # @user = User.find_by(name: params[:session][:name])
    # @projects = @user.projects
    @projects = Project.all
  end

  def new
    @project = Project.new
    # TODO: 将来マスターが増えるかもしれないので一応SQL文を発行しておく
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    # TODO: disabled タスク #654
    # params[:project][:duplicate_source].to_i.times { |cnt|
    #   create_sign("PPort#{cnt}", @project)
    #   create_sign("RPort#{cnt}", @project)
    # }

    if @project.save
      DatabaseManage.create!(
        backup_file_path: 'CAN/test', backup_date: Time.zone.today,
        project: @project
      )
      redirect_to projects_path
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to @project
    else
      flash[:danger] = 'プロジェクトの更新に失敗しました'
      render :edit
    end
  end

  def show
    return nil unless @project.nil?
    flash[:danger] = '選択されたプロジェクトが存在しません'
    redirect_to projects_path
  end

  def export_ecuc
    respond_to do |format|
      format.xml do
        send_data @project.to_ecuc_arxml, filename: 'Ecuc.arxml'
      end
    end
  end

  def export_systemdesign
    respond_to do |format|
      format.xml do
        send_data @project.to_systemdesign_arxml, filename: 'SystemDesign.arxml'
      end
    end
  end

  private

  # TODO: disabled タスク #654

  def set_project
    @project = Project.find(params[:id])
  end

  def create_sign(name, project)
    Sign.create!(
      name: name, active: '1', vartype: '2', unit: '3',
      exchange_rate: '4.0', priority: '5', input_module: '6',
      output_moduel: '7', input_period: '8', output_period: '9',
      access_level: '10', project: project,
      description: "project:#{project.name},name:#{name}"
    )
  end

  def project_params
    params.require(:project).permit(:name, :communication_protocol_id, :qines_version_id, :byte_order)
  end
end
