module ComConst
    # Rails Rootディレクトリ
    RailsRootDir = Rails.root
    # Databaase 製品名
    DbAdapter = Rails.configuration.database_configuration[Rails.env]["adapter"]
    # Database
    Database = Rails.configuration.database_configuration[Rails.env]["database"]
    # Database ディレクトリ
    DatabaseDir =  "#{RailsRootDir}/#{Database}"
    # ダウンロードTempディレクトリ
    DownloadTempDir = "#{RailsRootDir}/tmp/download"
end
