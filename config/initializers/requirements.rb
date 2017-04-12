# 指定directoryをrequireする
autsar403path = File.expand_path('lib/autosar403', ENV['RAILS_ROOT'])
Dir[Rails.root.join("#{autsar403path}/*.rb")].sort.each { |f| require f }

commonpath = File.expand_path('lib/common', ENV['RAILS_ROOT'])
Dir[Rails.root.join("#{commonpath}/*.rb")].sort.each { |f| require f }

# ダウンロードTempディレクトリが無ければ作成
MakeDir.mkdir(ComConst::DownloadTempDir)
