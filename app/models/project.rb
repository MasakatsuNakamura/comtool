class Project < ApplicationRecord
  belongs_to :communication_protocol
  belongs_to :qines_version

  # TODO:disabled タスク #654
  attr_accessor :duplicate_source

  validates :name,
            presence: true,
            length: { maximum: 50 }

  def self.getOwnProjects(_user)
    # TODO: メンバー機能の実装
    Project.all
  end

  def self.qines_version_number
    ''
  end
end
