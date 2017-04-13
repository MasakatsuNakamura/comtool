class ConfigController < ApplicationController
  include ArxmlExporter

  def export_ecuc
    # ComStack の Ecuc.arxml を作成
    arxml = export_ecuc_comstack(
                    project:Project.find_by_id(session[:project]),
                    messages: Message.getOwnMessages(session[:project]))

    # クライアントへダウンロード
    send_data(
      arxml,
      type: 'application/octet-stream',
      # 出力ファイル名
      filename: 'Ecuc.arxml'
    )
  end

  def export_systemdesign
    # SIGNAL関連 の SystemDesign.arxml を作成
    arxml = export_signals(
                    project:Project.find_by_id(session[:project]),
                    messages: Message.getOwnMessages(session[:project]))

    # クライアントへダウンロード
    send_data(
      arxml,
      type: 'application/octet-stream',
      # 出力ファイル名
      filename: 'SystemDesign.arxml'
    )
  end
end
