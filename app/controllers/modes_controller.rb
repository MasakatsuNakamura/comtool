class ModesController < ApplicationController
  before_action :set_project, only: %w[index new create]
  before_action :set_mode, only: %w[show edit update destroy]

  def index; end

  def new
    @mode = Mode.new
    @mode.project = @project
  end

  def create
    @mode = Mode.new(mode_params)
    @mode.project = @project
    if @mode.save
      redirect_to project_modes_path(@mode.project_id)
    else
      render :new
    end
  end

  def show; end

  def edit
    @project = @mode.project
  end

  def update
    if @mode.update(mode_params)
      redirect_to project_modes_path(@mode.project_id)
    else
      render :edit
    end
  end

  def destroy
    if @mode.destroy
      redirect_to project_modes_path(@mode.project_id)
    else
      redirect_to project_modes_path(@mode.project_id), danger: 'メッセージの削除に失敗しました'
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_mode
    @mode = Mode.find(params[:id])
  end

  def mode_params
    params[:mode].permit(:title, :project_id, :param)
  end
end
