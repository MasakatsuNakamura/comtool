class Config < ApplicationRecord
  # CSVを作成する
  #=== Args
  #-options_ : CSVの生成オプション
  #-project : project_id
  def self.to_csv(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true, project_id: nil)
    configs = project_id ? Config.where(project_id: project_id) : Config.all
    CSV.generate(encoding: encoding, row_sep: row_sep, force_quotes: force_quotes) do |csv|
      csv << column_names
      csv.concat configs.map(&:attributes).map(&:values)
      configs.each { |config| csv << config.attributes.values }
    end
  end
end
