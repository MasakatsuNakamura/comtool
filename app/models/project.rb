class Project < ApplicationRecord
  belongs_to :communication_protocol
  belongs_to :qines_version

  # TODO:delete 中間リリース用暫定処理 (タスク #579)
  attr_accessor :duplicate_source

  validates :name,
            presence: true,
            length: { maximum: 50 }

  def self.getOwnProjects(_user)
    # TODO: 自身に紐づくプロジェクトを取得する？
    Project.all
  end

  def self.qines_version_number
    ''
  end
end
