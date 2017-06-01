# coding: utf-8

class Message < ApplicationRecord
  attr_accessor :duplicate_source

  belongs_to :project
  has_many :com_signals, dependent: :destroy
  enum data_frame: %w[standard_can extended_can]

  accepts_nested_attributes_for :com_signals, reject_if: true
  validates_associated :com_signals

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :project_id },
            length: { maximum: 50 },
            format: { with: /\A[a-zA-Z]\w*\z/, message: '半角英数とアンダースコアが利用できます' }

  validates :canid,
            presence: true,
            numericality: true

  validate :message_layout_should_be_correct

  def com_signals_build
    unused_name =
      project.com_signals.where("name like 'Signal%'").map do |com_signal|
        com_signal.name =~ /Signal([0-9]+)/i
        $LAST_MATCH_INFO[1].to_i
      end.max + 1

    # default com_signal
    com_signals.build(
      name: "Signal#{unused_name}",
      unit: 'Enter a unit',
      description: 'Enter a description',
      bit_offset: 0,
      bit_size:   1,
      message: self,
      project: project
      #       sign: Sign.find_by(project_id: self.project_id)
    )
  end

  def duplicate_from_arxml(duplicate_source)
    # TODO: arxmlからメッセージのプロパティを読み込む
    self.canid = 100
    self.txrx = duplicate_source ? duplicate_source.to_i % 2 : 0
    self.baudrate = 2
    self.bytesize = 1
    com_signals_build
    self
  end

  def unused_sign
    used_signs = com_signals.map(&:sign_id)
    unused_signs = Sign.where(project_id: project_id).reject do |sign|
      used_signs.include?(sign.id)
    end
    unused_signs.empty? ? nil : unused_signs[0].id
  end

  def unused_bit
    unused_bit = Array.new(bytesize * 8, true)
    com_signals.each do |c|
      offset = c.bit_offset
      c.bit_size.times do
        unused_bit[offset] = false if offset < bytesize * 8
        offset += next_bit(offset)
      end
    end
    unused_bit.index(true)
  end

  private

  def message_layout_should_be_correct
    message_layout = Array.new(bytesize * 8, false)
    com_signals.each do |c|
      offset = c.bit_offset
      c.bit_size.times do
        if message_layout[offset].nil?
          errors.add(:bit_offset, 'メッセージレイアウトが範囲外です')
          break
        elsif message_layout[offset]
          errors.add(:bit_offset, 'メッセージレイアウトが重複しています')
          break
        end
        message_layout[offset] = true
        offset += next_bit(offset)
      end
    end
  end

  def next_bit(offset)
    if project.little_endian?
      1
    elsif (offset % 8).zero?
      15
    else
      -1
    end
  end
end
