# 指定directoryをrequireする
Dir[Rails.root.join("lib/common/*.rb")].sort.each { |f| require f }

# ダウンロードTempディレクトリが無ければ作成
MakeDir.mkdir(ComConst::DownloadTempDir)
