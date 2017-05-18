require 'csv'
require 'tempfile'
class DatabaseManagesController < ApplicationController
    before_action :set_database_manage, only: [:show]

  # ＤＢ管理の表示
  def show
    if @database_manage == nil
      flash[:danger] = '選択されたＤＢ管理が存在しません'
      redirect_to project_path(params[:project])
    end
  end

# Todo 復活は未実装
  def restore
    redirect_to database_manage_path(:project => params[:project_id])
  end
  # 符号ＤＢのCSVエクスポート
  def sign_csvexport
    project_id = params[:project_id]
    project_id = nil if params[:all]
    csv = Sign.to_csv({encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true}, project_id)
    send_data(
      # ファイル
      csv,
      # 固定
      type: 'application/octet-stream',
      # ダウンロード出力ファイル名
      filename: 'Sign.csv'
    )
  end

  # 符号ＤＢのBinaryエクスポート
  def sign_binexport
    export(:signs)
  end

  # コンフィグＤＢのCSVエクスポート
  def config_csvexport
    project_id = params[:project_id]
    project_id = nil if params[:all]
    csv = Config.to_csv({encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true}, project_id)
    send_data(
      # ファイル
      csv,
      # 固定
      type: 'application/octet-stream',
      # ダウンロード出力ファイル名
      filename: 'Config.csv'
    )
  end

  # コンフィグＤＢのBinaryエクスポート
  def config_binexport
    export(:configs)
  end

  private
    # DatabaseManageを外部キーで読込む
    def set_database_manage
      @database_manage = DatabaseManage.find_by_project_id(params[:project])
    end

    # エキスポート
    def export(tablename)
      temp_directory = ComConst::DownloadTempDir
      # Tempfileを利用し一時ファイルを生成、そのTempfile名をダウンロード用一時ファイルとしてexport出力する
      tmpfl = Tempfile.new(tablename.to_s, temp_directory)
      dump_outfile =tmpfl.path
      dump_outfile += ".sql"
      dump = BatchExport.new.invoke(tablename,dump_outfile)
      if dump
        file = File.open(dump_outfile, "rb")
        contents = file.read
        file.close

        # バッチでExportしたダウンロード用一時ファイルを削除する
        File.delete(dump_outfile) if File.exist?(dump_outfile)

        send_data(
          # ファイル
          contents,
          # 固定
          type: 'application/octet-stream',
          # ダウンロード出力ファイル名
          filename: tablename.to_s + ".sql"
        )
      else
        raise "BatchExport error"
      end
    rescue Exception => e
      logger.error "#{tablename.to_s} export error Exception=#{e.to_s}"
      flash[:danger] = "#{tablename.to_s} Binary Exportに失敗しました"
      redirect_to database_manage_path(:project => params[:project_id])
    ensure
      # Tempfileをリアルタイム削除する
      tmpfl.close(true) if tmpfl
    end
end
