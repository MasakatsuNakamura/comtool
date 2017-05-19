class MessageValidator < ActiveModel::Validator
  def validate(record)
    msg = record
    project = Project.find_by_id(msg.project_id)

    message_layout = Array.new(msg.bytesize*8, false)
    msg.com_signals.each do |c|
      offset = c.bit_offset
      bit_size = c.bit_size
      bit_size.times do
        if message_layout[offset].nil?
          msg.errors[:bit_offset] << 'メッセージレイアウトが範囲外です'
          break
        elsif message_layout[offset]
          msg.errors[:bit_offset] << 'メッセージレイアウトが重複しています'
          break
        end
        message_layout[offset] = true
        if project.little_endian?
          offset += 1
        elsif (offset % 8).zero?
          offset += 15
        else
          offset -= 1
        end
      end
    end
  end
end

class Message < ApplicationRecord
  attr_accessor :duplicate_source

  belongs_to :project
  has_many :com_signals, dependent: :destroy
  enum data_frame: %w[standard_can extended_can]

  accepts_nested_attributes_for :com_signals, reject_if: true
  validates_associated :com_signals
  include ActiveModel::Validations
  validates_with MessageValidator

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :project_id },
            length: { maximum: 50 },
            format: { with: /\A[a-zA-Z]\w*\z/, message: "半角英数とアンダースコアが利用できます"}

  validates :canid,
            presence: true,
            numericality: true

  def com_signals_build
    # default com_signal
    project = Project.find(self.project_id)
    c = com_signals.build(
      name: "Signal#{project.com_signals.length}",
      unit: 'Enter a unit',
      description: 'Enter a description',
      bit_offset: 0,
      bit_size:   1,
      message: self,
      project: Project.find(project_id)
      #       sign: Sign.find_by(project_id: self.project_id)
    )
  end

  def Message.duplicate_from_arxml(params, opt = {})
    m = Message.new(params)

    # TODO: arxmlからメッセージのプロパティを読み込む
    m.canid = 100
    m.txrx = opt[:duplicate_source] ? opt[:duplicate_source].to_i % 2 : 0
    m.baudrate = 2
    m.bytesize = 1

    if opt[:project]
      prj = opt[:project]
      m.project = Project.find(prj)
      c = m.com_signals_build
    end
    m
  end
end
