
class ComSignal < ApplicationRecord
  belongs_to :message
  belongs_to :sign, optional: true

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false, scope: :message_id },
    length: { maximum: 50 },
    format: { with: /\A[a-zA-Z]\w*\z/, message: "半角英数とアンダースコアが利用できます"}

  validates :bit_offset,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :bit_size,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

end
