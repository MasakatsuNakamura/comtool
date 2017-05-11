class Project < ApplicationRecord
  has_many :messages
  enum byte_order: %w[big_endian little_endian]
  enum qines_version_id: { v1_0: 1, v2_0: 2 }
  enum communication_protocol_id: { can: 1 }

  # TODO:disabled タスク #654
  attr_accessor :duplicate_source

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 50 },
            format: { with: /\A[a-zA-Z]\w*\z/, message: "半角英数とアンダースコアが利用できます"}

  def self.qines_version_number
    ''
  end
end
