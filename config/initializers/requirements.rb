# 指定directoryをrequireする
autsarpath = File.expand_path('lib/autosar', ENV['RAILS_ROOT'])
Dir[Rails.root.join("#{autsarpath}/*.rb")].sort.each { |f| require f }

commonpath = File.expand_path('lib/common', ENV['RAILS_ROOT'])
Dir[Rails.root.join("#{commonpath}/*.rb")].sort.each { |f| require f }

# ダウンロードTempディレクトリが無ければ作成
MakeDir.mkdir(ComConst::DownloadTempDir)
