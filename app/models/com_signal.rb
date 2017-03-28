
class ComSignalValidator < ActiveModel::Validator
  def validate(record)
    msg = Message.find_by_id(record.message_id)
    unless msg.nil? then
      begin
        if (record.bit_offset > msg.bytesize*8)
          record.errors[:bit_offset] << 'メッセージレイアウトが範囲外です'
        end

        if msg.byte_order == :little_endian then
          if (record.bit_size > (msg.bytesize*8 - record.bit_offset))
            record.errors[:bit_size] << 'メッセージレイアウトが範囲外です'
          end
        else
          byte_pos = record.bit_offset / 8
          bit_pos  = record.bit_offset % 8

          if (record.bit_size > (msg.bytesize*8 - (byte_pos + 1)*8 + (bit_pos+1)))
            record.errors[:bit_size] << 'メッセージレイアウトが範囲外です'
          end
        end
      rescue => e
        # 例外が発生する場合は、他のバリデーションでエラーが発生する
      end
    end
  end
end

class ComSignal < ApplicationRecord
  belongs_to :message
  belongs_to :sign

  include ActiveModel::Validations
  validates_with ComSignalValidator

  validates :name,
    presence: true,
    length: { maximum: 50 }

  validates :bit_offset,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :bit_size,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validates :sign,
    uniqueness: { scope: :message_id,message: "シグナルの符号が重複しています" },
    presence: true
end
