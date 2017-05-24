require 'csv'
require 'tempfile'
class DatabaseManagesController < ApplicationController
  before_action :set_database_manage, only: [:show]

  # ＤＢ管理の表示
  def show
    return nil unless @database_manage.nil?
    redirect_to project_path(params[:project]), danger: '選択されたＤＢ管理が存在しません'
  end

  # TODO: 復活は未実装
  def restore
    redirect_to database_manage_path(params[:id])
  end

  # 符号ＤＢのCSVエクスポート
  def sign_csvexport
    project_id = params[:project_id]
    project_id = nil if params[:all]
    csv = Sign.to_csv(project_id: project_id)
    send_data csv, filename: 'Sign.csv'
  end

  # 符号ＤＢのBinaryエクスポート
  def sign_binexport
    export(:signs)
  end

  # コンフィグＤＢのCSVエクスポート
  def config_csvexport
    project_id = params[:project_id]
    project_id = nil if params[:all]
    csv = Config.to_csv(project_id: project_id)
    send_data csv, filename: 'Config.csv'
  end

  # コンフィグＤＢのBinaryエクスポート
  def config_binexport
    export(:configs)
  end

  private

  # DatabaseManageを外部キーで読込む
  def set_database_manage
    @database_manage = DatabaseManage.find_by(project_id: params[:project])
  end

  # エキスポート
  def export(tablename)
    tempfile = Tempfile.new
    BatchExport.new.invoke(tablename, tempfile)
    tempfile.rewind
    contents = tempfile.read
    send_data contents, filename: "#{tablename}.sql"
  rescue StandardError => e
    logger.error "#{tablename} export error Exception=#{e}"
    redirect_to database_manage_path(project_id: params[:project_id]), danger: "#{tablename} Binary Exportに失敗しました"
  ensure
    tempfile&.close(true)
  end
end
