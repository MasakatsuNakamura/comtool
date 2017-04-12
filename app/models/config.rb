class Config < ApplicationRecord
  # CSVを作成する
  #=== Args
  #-options_ : CSVの生成オプション
  #-project : project_id
    def self.to_csv(options = {},project_id=nil)
      CSV.generate(options) do |csv|
        csv << column_names
        if project_id
          Config.where(project_id: project_id).each do |config|
              csv << config.attributes.values
          end
        else
          Config.all.each do |config|
              csv << config.attributes.values
          end
        end
      end

    end
end
