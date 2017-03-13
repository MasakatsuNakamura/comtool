class Project < ApplicationRecord
  belongs_to :communication_protocol
  belongs_to :qines_version
  def self.getOwnProjects(_user)
    # TODO: 自身に紐づくプロジェクトを取得する？
    Project.all
  end

  def self.qines_version_number
    ''
  end
end
