class MessageValidator < ActiveModel::Validator
  def validate(record)
    msg = record

    message_layout = Array.new(msg.bytesize*8, false)
    msg.com_signals.each do |c|
      if msg.byte_order == :littel_endian then
        c.bit_size.times do |bit|
          if message_layout[bit + c.bit_offset] then
            msg.errors[:bit_offset] << 'メッセージレイアウトが重複しています'
            break
          end
          message_layout[bit + c.bit_offset] = true
        end
      else
        offset = c.bit_offset
        bit_size = c.bit_size
        while bit_size > 0
          if message_layout[offset] then
            msg.errors[:bit_offset] << 'メッセージレイアウトが重複しています'
            break
          end
          message_layout[offset] = true

          bit_size -= 1
          if offset % 8 == 0 then
            offset += 15
          else
            offset -= 1
          end
        end
      end
    end
  end
end

class Message < ApplicationRecord
  attr_accessor :duplicate_source

  belongs_to :project
  has_many :com_signals, dependent: :destroy

  accepts_nested_attributes_for :com_signals, reject_if: true
#  validates_associated :com_signals
  include ActiveModel::Validations
  validates_with MessageValidator

  validates :name,
            presence: true,
            length: { maximum: 50 }

  def self.getOwnMessages(project)
    Message.where(project_id: project)
  end

  def com_signals_build
    # default com_signal
    c = self.com_signals.build(
        name: 'Enter a name',
        unit: 'Enter a unit',
        description: 'Enter a description',
        bit_offset: 0,
        bit_size:   1,
        message: self,
        sign: Sign.find_by(project_id: self.project_id)
      )
  end

  def Message.duplicate_from_arxml(params, opt = {})
    m = Message.new(params)

    # TODO arxmlからメッセージのプロパティを読み込む
    if (opt[:duplicate_source]) then
      m.canid = 100
      m.txrx  = opt[:duplicate_source].to_i % 2
      m.baudrate = 2
      m.bytesize  = 1
    else
      m.canid = 100
      m.txrx  = 0
      m.baudrate = 2
      m.bytesize  = 1
    end

    if (opt[:project]) then
      prj = opt[:project]

      m.project = Project.find_by_id(prj)
      c = m.com_signals_build
    end

    m
  end

  def byte_order
    # TODO: littel_endian
    :big_endian
  end

end
