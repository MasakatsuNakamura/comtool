class ConfigController < ApplicationController
  def export
    # 1．ARXMLを読込み
    # 2．DBに従って、データの変更
    # 3．ARXMLの出力

    # 4．クライアントへダウンロード
    # サーバ上にファイルを保存しているのであれば、send_fileを使用する(でも可能)
    send_data(
      # ファイルパス
      # File.read("public/img/#{params[:filename]}"),
      File.read('test/arxml/Ecuc.arxml'),
      # 固定
      type: 'application/octet-stream',
      # 出力ファイル名
      filename: 'Ecuc.arxml'
    )
  end
end
