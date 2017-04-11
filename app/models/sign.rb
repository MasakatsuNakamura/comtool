class Sign < ApplicationRecord
  belongs_to :project

  def self.getOwnSigns(project)
    Sign.where(project_id: project)
  end

# CSVを作成する
#=== Args
#-options_ : CSVの生成オプション
#-project : project_id
  def self.to_csv(options = {},project_id=nil)
    CSV.generate(options) do |csv|
      csv << column_names
      if project_id
        Sign.where(project_id: project_id).each do |sign|
            csv << sign.attributes.values
        end
      else
        Sign.all.each do |sign|
            csv << sign.attributes.values
        end
      end
    end
  end

end
