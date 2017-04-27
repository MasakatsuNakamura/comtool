class Project < ApplicationRecord
  belongs_to :communication_protocol
  belongs_to :qines_version
  enum byte_order: {big_endian:0, little_endian:1}

  # TODO:disabled タスク #654
  attr_accessor :duplicate_source

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 50 },
            format: { with: /\A[a-zA-Z]\w*\z/, message: "半角英数とアンダースコアが利用できます"}

  def self.getOwnProjects(_user)
    # TODO: メンバー機能の実装
    Project.all
  end

  def self.qines_version_number
    ''
  end
end
