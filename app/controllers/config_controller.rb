class ConfigController < ApplicationController
  include ArxmlExporter

  def export
    # ComStack の ARXML を作成
    arxml = export_comstack

    # クライアントへダウンロード
    send_data(
      arxml,
      type: 'application/octet-stream',
      # 出力ファイル名
      filename: 'Ecuc.arxml'
    )
  end
end
