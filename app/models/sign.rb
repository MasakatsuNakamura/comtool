# coding: utf-8

class Sign < ApplicationRecord
  belongs_to :project

  # CSVを作成する
  #=== Args
  #-options_ : CSVの生成オプション
  #-project : project_id
  def self.to_csv(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true, project_id: nil)
    signs = project_id ? Sign.where(project_id: project_id) : Sign.all
    CSV.generate(encoding: encoding, row_sep: row_sep, force_quotes: force_quotes) do |csv|
      csv << column_names
      signs.each { |sign| csv << sign.attributes.values }
    end
  end
end
